class CrAccessGroup < ApplicationRecord
  include Encodable

  belongs_to :cr_group
  belongs_to :cr_access_data

  STATUSES = {
    pending: 'pending',
    accepted: 'accepted',
  }.freeze

  ACCESS_LEVELS = {
    anyone: 'anyone',
    owner: 'owner',
  }.freeze

  TTL = 1.week.to_i.freeze

  enum status: STATUSES
  enum access_level: ACCESS_LEVELS

  validates_uniqueness_of :cr_group_id, scope: :cr_access_data_id

  def invitation_token
    encoded_token(payload: { cr_access_group_id: id })
  end

  def send_invitation
    CrGroupMailer.invite_cr_user(cr_access_data, self).deliver_later
  end

  def self.accept_invite(token)
    find_by(id: decoded_data(token)&.fetch('cr_access_group_id'))&.accepted!
  end

  def self.by_user(user)
    joins(cr_access_data: :users).where(cr_access_data: { users: user })
  end

  def self.fetch_cr_data
    cr_data_list = all.to_a
    FetchPatientData.assign_cr_data_attributes(cr_data_list.map(&:cr_access_accessor))
    cr_data_list
  end

  def cr_access_accessor
    @cr_access_accessor ||= cr_access_data
  end
end
