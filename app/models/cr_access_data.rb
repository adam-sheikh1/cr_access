class CrAccessData < ApplicationRecord
  include QrCodeable
  include Encodable

  belongs_to :user, optional: true
  belongs_to :parent, class_name: 'CrAccessData', foreign_key: :parent_id, optional: true

  has_one_attached :profile_picture

  has_one :fv_code, as: :fv_codable, dependent: :destroy

  has_many :children, class_name: 'CrAccessData', foreign_key: :parent_id, dependent: :destroy
  has_many :cr_access_groups, dependent: :destroy
  has_many :cr_groups, through: :cr_access_groups
  has_many :accepted_access_groups, -> { where(status: 'accepted') }, class_name: 'CrAccessGroup'
  has_many :accepted_cr_groups, through: :accepted_access_groups, class_name: 'CrGroup', source: :cr_group

  attr_accessor :setter_errors

  validate :validate_no_setter_errors
  validates :profile_picture, blob: { content_type: %w[image/jpg image/jpeg image/png], size_range: 1..3.megabytes }

  accepts_nested_attributes_for :children

  after_commit :mark_registered, on: :create
  after_save :set_fv_code
  after_save :make_primary

  VACCINATION_STATUSES = {
    not_vaccinated: 'not_vaccinated',
    partially_vaccinated: 'partially_vaccinated',
    fully_vaccinated: 'fully_vaccinated',
  }.freeze

  TTL = 1.week.to_i.freeze

  enum vaccination_status: VACCINATION_STATUSES

  def self.permitted_params_list
    %i[id encoded_attributes profile_picture]
  end

  def self.permitted_params
    permitted_params_list << [children_attributes: %i[id encoded_attributes profile_picture]]
  end

  def gender=(sex)
    downcased_gender = sex.to_s.downcase

    self[:gender] = 'male' and return if downcased_gender == 'm'
    self[:gender] = 'female' and return if downcased_gender == 'f'
    self[:gender] = 'other' and return if downcased_gender == 'o'

    self[:gender] = sex
  end

  def initialize_children(params)
    params.each do |child_params|
      children.find_or_initialize_by(prepmod_patient_id: child_params['prepmod_patient_id']).assign_attributes(child_params)
    end
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def encoded_attributes
    JWT.encode(attributes.except('id', 'created_at', 'updated_at'), ENV['SECRET_KEY_BASE'], 'HS256')
  end

  def encoded_attributes=(attributes)
    @setter_errors ||= {}
    @setter_errors[:attributes] ||= []

    begin
      assign_attributes(JWT.decode(attributes, ENV['SECRET_KEY_BASE'], true, { algorithm: 'HS256' }).first)
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
      @setter_errors[:attributes] << 'data is invalid/tempered'
    end
  end

  def mark_registered
    HTTParty.put("#{ENV['PREPMOD_URL']}/api/v1/patients/update_registered?token=#{prepmod_patient_id}",
                 basic_auth: { username: ENV['PREPMOD_AUTH_USERNAME'], password: ENV['PREPMOD_AUTH_PASSWORD'] })
  end

  def validate_no_setter_errors
    return if setter_errors.blank?

    setter_errors.each do |attribute, messages|
      messages.each do |message|
        errors.add(attribute, message)
      end
    end

    setter_errors.empty?
  end

  def covidreadi_id=(_token); end

  def guardian
    return user if parent_id.blank?

    parent.user
  end

  def self.by_user(user)
    where(id: user.cr_access_data).or(where(id: user.accessible_cr_data))
  end

  def self.share_data(user)
    transaction do
      data = user.accessible_cr_data << where.not(id: user.accessible_cr_data.ids)
      CrDataUser.where(id: data.select('cr_data_users.id').map(&:id)).send_invitation(user.id)
    end
  end

  def linked_with?(user)
    user.id != user_id
  end

  private

  def set_fv_code
    return unless saved_change_to_vaccination_status?
    return fv_code&.destroy unless fully_vaccinated?
    return if fv_code.present?

    create_fv_code
  end

  def make_primary
    return if parent_id.present?
    return unless saved_change_to_primary? && primary?

    user.reset_primary_data(id)
  end
end
