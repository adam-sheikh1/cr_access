class CrGroup < ApplicationRecord
  include QrCodeable
  include Encodable

  TTL = 1.week.to_i.freeze

  belongs_to :user

  has_one :fv_code, as: :fv_codable, dependent: :destroy

  has_many :cr_access_groups
  has_many :cr_access_data, through: :cr_access_groups

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

  def invitation_token(cr_access_id)
    encoded_token(payload: { group_id: id, cr_access_id: cr_access_id })
  end

  def self.add_user(token)
    data = decoded_data(token)
    return false if data.blank?

    group = find_by(id: data['group_id'])
    return true if group.cr_access_data.ids.include?(data['cr_access_id'])

    cr_access = CrAccessData.find_by(id: data['cr_access_id'])
    return false if group.blank? || cr_access.blank?

    group.cr_access_data << cr_access
  end

  def accessible_to?(user)
    user.id == user_id || (user.cr_access_datum_ids & cr_access_datum_ids).any?
  end

  def invite(fv_code)
    invitee = FvCode.cr_access.find_by(code: fv_code)&.fv_codable
    return false if invitee.blank?

    CrGroupMailer.invite_cr_user(invitee.id, id).deliver_later
  end

  def owner?(user)
    user_id == user.id
  end

  def self.by_user(user)
    where(id: user.cr_groups).or(where(id: user.primary_groups))
  end

  private

  def add_primary_to_self
    cr_access_data << user.primary_cr_data if user.primary_cr_data.present?
  end
end
