class CrGroup < ApplicationRecord
  include QrCodeable
  include Encodable

  TTL = 1.week.to_i.freeze

  belongs_to :user

  has_one :fv_code, as: :fv_codable, dependent: :destroy

  has_many :cr_access_groups, dependent: :destroy
  has_many :cr_access_data, through: :cr_access_groups
  has_many :accepted_access_groups, -> { accepted }, class_name: 'CrAccessGroup'
  has_many :accepted_cr_data, through: :accepted_access_groups, class_name: 'CrAccessData', source: :cr_access_data

  validates_presence_of :group_type, :name
  validates_uniqueness_of :name, scope: %i[group_type user_id], case_sensitive: false

  TYPES = {
    family: 'family',
    friends: 'friends',
    school: 'school',
    employer: 'employer',
    business: 'business',
    other: 'other'
  }.freeze

  enum group_type: TYPES

  after_create :create_fv_code
  after_create :add_primary_to_self

  def accessible_to?(user)
    user.id == user_id || (user.cr_access_datum_ids & accepted_cr_datum_ids).any?
  end

  def invite(params)
    invitee = find_invitee(params)
    return false if invitee.blank? || cr_access_datum_ids.include?(invitee.id)

    CrAccessGroup.create(cr_group: self, cr_access_data: invitee).send_invitation
  end

  def find_invitee(params)
    data = FetchPatientData.find_patient(params[:first_name], params[:last_name], params[:email])
    CrAccessData.find_by(external_id: data.patient_id)
  end

  def owner?(user)
    user_id == user.id
  end

  def self.by_user(user)
    where(id: user.cr_groups).or(where(id: user.primary_groups))
  end

  def cr_access_groups_by_user(user)
    return cr_access_groups if owner?(user)

    cr_access_groups.anyone.or(cr_access_groups.where(id: cr_access_groups.by_user(user)))
  end

  def cr_data_accessor
    data = cr_access_data.to_a
    FetchPatientData.assign_cr_data_attributes(data)
    data
  end

  private

  def add_primary_to_self
    accepted_cr_data << user.primary_cr_data if user.primary_cr_data.present?
  end
end
