class CrAccessData < ApplicationRecord
  include QrCodeable
  include Encodable

  attr_accessor :primary, :setter_errors

  belongs_to :parent, class_name: 'CrAccessData', foreign_key: :parent_id, optional: true

  has_one_attached :profile_picture

  has_one :primary_data, -> { where(primary: true) }, class_name: 'CrDataUser'
  has_one :user, through: :primary_data
  has_one :fv_code, as: :fv_codable, dependent: :destroy

  has_many :cr_data_users, dependent: :destroy
  has_many :children, class_name: 'CrAccessData', foreign_key: :parent_id, dependent: :destroy
  has_many :cr_access_groups, dependent: :destroy
  has_many :cr_groups, through: :cr_access_groups
  has_many :accepted_access_groups, -> { where(status: 'accepted') }, class_name: 'CrAccessGroup'
  has_many :accepted_cr_groups, through: :accepted_access_groups, class_name: 'CrGroup', source: :cr_group

  validate :validate_no_setter_errors
  validates :profile_picture, blob: { content_type: %w[image/jpg image/jpeg image/png], size_range: 1..3.megabytes }, presence: true

  accepts_nested_attributes_for :children

  after_commit :mark_registered, on: :create
  after_save :set_fv_code

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
    encoded_token(payload: attributes.except('id', 'created_at', 'updated_at').merge({ primary: primary }))
  end

  def encoded_attributes=(attributes)
    @setter_errors ||= {}
    @setter_errors[:attributes] ||= []

    begin
      assign_attributes(self.class.decoded_data(attributes).except('exp'))
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
    time = DateTime.now
    data = where.not(id: user.all_cr_user_ids).map do |cr_data|
      {
        user_id: user.id,
        cr_access_data_id: cr_data.id,
        created_at: time,
        updated_at: time,
        data_type: CrDataUser::DATA_TYPES[:invited]
      }
    end

    return false if data.blank?

    CrDataUser.where(id: CrDataUser.upsert_all(data, unique_by: %i[cr_access_data_id user_id]).rows.flatten).send_invitation(user.id)
  end

  private

  def set_fv_code
    return unless saved_change_to_vaccination_status?
    return fv_code&.destroy unless fully_vaccinated?
    return if fv_code.present?

    create_fv_code
  end
end
