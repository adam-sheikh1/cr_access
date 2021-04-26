class CrGroup < ApplicationRecord
  include QrCodeable
  include Encodable

  TTL = 1.week.to_i.freeze

  belongs_to :user

  has_one :fv_code, as: :fv_codable, dependent: :destroy

  has_many :cr_access_groups, dependent: :destroy
  has_many :cr_access_data, through: :cr_access_groups
  has_many :accepted_access_groups, -> { where(status: 'accepted') }, class_name: 'CrAccessGroup'
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

  def invite(fv_code)
    transaction do
      invitee = FvCode.cr_access.find_by(code: fv_code)&.fv_codable
      return false if invitee.blank? || cr_access_datum_ids.include?(invitee.id)

      invitee = cr_access_data << invitee
      CrAccessGroup.where(id: invitee.select('cr_access_groups.id').map(&:id)).first.send_invitation
    end
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
