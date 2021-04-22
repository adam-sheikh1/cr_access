class CrDataUser < ApplicationRecord
  include Encodable

  belongs_to :user
  belongs_to :cr_access_data

  STATUSES = {
    pending: 'pending',
    accepted: 'accepted',
  }.freeze

  TTL = 1.week.to_i.freeze

  enum status: STATUSES

  validates_uniqueness_of :cr_access_data_id, scope: [:user_id]

  def self.invitation_token(user_id)
    encoded_token(payload: { user_id: user_id, cr_data_user_ids: ids })
  end

  def self.send_invitation(user_id)
    CrAccessMailer.share_data(user_id, ids).deliver_later
  end
end
