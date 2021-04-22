class CrAccessGroup < ApplicationRecord
  include Encodable

  belongs_to :cr_group
  belongs_to :cr_access_data

  STATUSES = {
    pending: 'pending',
    accepted: 'accepted',
  }.freeze

  TTL = 1.week.to_i.freeze

  enum status: STATUSES

  validates_uniqueness_of :cr_group_id, scope: :cr_access_data_id

  def invitation_token
    encoded_token(payload: { cr_group_id: id, cr_access_id: cr_access_data_id })
  end

  def send_invitation
    CrGroupMailer.invite_cr_user(cr_access_data_id, id).deliver_later
  end

  def self.accept_invite(token)
    find_by(id: decoded_data(token)&.fetch('cr_group_id'))&.accepted!
  end
end
