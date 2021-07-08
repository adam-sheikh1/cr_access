class CrDataUser < ApplicationRecord
  include Encodable

  belongs_to :user
  belongs_to :cr_access_data

  STATUSES = {
    pending: 'pending',
    accepted: 'accepted',
  }.freeze

  DATA_TYPES = {
    prepmod: 'prepmod',
    invited: 'invited',
  }.freeze

  TTL = 1.week.to_i.freeze

  scope :by_user, ->(user) { where(user: user) }

  enum status: STATUSES
  enum data_type: DATA_TYPES

  after_save :make_primary
  after_create :set_primary

  validates_uniqueness_of :cr_access_data_id, scope: [:user_id]

  def self.invitation_token(user_id)
    encoded_token(payload: { user_id: user_id, cr_data_user_ids: ids })
  end

  def self.fetch_cr_data
    cr_data_list = all.to_a
    FetchPatientData.assign_cr_data_attributes(cr_data_list.map(&:cr_access_accessor))
    cr_data_list
  end

  def cr_access_accessor
    @cr_access_accessor ||= cr_access_data
  end

  def invitation_token(user_id)
    encoded_token(payload: { user_id: user_id, cr_data_user_ids: [id] })
  end

  def send_invitation(user_id)
    CrAccessMailer.share_data(user_id, id).deliver_later
  end

  def accepted?
    prepmod? || status == STATUSES[:accepted]
  end

  def primary=(value)
    self[:primary] = invited? ? false : value
  end

  private

  def set_primary
    update(primary: cr_access_data.primary)
  end

  def make_primary
    return unless saved_change_to_primary? && primary?

    user.reset_primary_data(id)
  end
end
