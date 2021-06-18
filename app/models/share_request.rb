class ShareRequest < ApplicationRecord
  include Encodable

  belongs_to :user
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id', optional: true

  has_many :request_vaccinations, dependent: :destroy
  has_many :vaccination_records, through: :request_vaccinations

  attr_accessor :data_confirmation

  validate :valid_data, if: -> { data_confirmation.present? }
  validate :validate_own_email

  validates_format_of :data, with: Devise::email_regexp
  validates_format_of :data_confirmation, with: Devise::email_regexp, if: -> { data_confirmation.present? }

  validates_presence_of :data

  before_save :set_recipient, :set_type

  after_create :notify_recipient

  RELATIONSHIPS = %i[parent_guardian child spouse employer other].freeze

  STATUSES = {
    pending: 'pending',
    accepted: 'accepted'
  }.freeze

  TYPES = {
    registered: 'registered',
    not_registered: 'not_registered'
  }.freeze

  enum status: STATUSES
  enum request_type: TYPES
  enum relationship: RELATIONSHIPS

  def mark_accepted
    return if accepted?

    accepted!
    share_vaccinations
    recipient.update_attribute('two_fa_code', nil)
    update_attribute('accepted_at', DateTime.now)
  end

  def share_vaccinations
    time = DateTime.now
    records = (vaccination_record_ids - recipient.accessible_vaccination_ids).map do |id|
      {
        relationship: relationship,
        user_id: recipient.id,
        vaccination_record_id: id,
        created_at: time,
        updated_at: time
      }
    end

    VaccinationUser.upsert_all(records, unique_by: %i[user_id vaccination_record_id])
  end

  private

  def valid_data
    return if data == data_confirmation

    errors.add(:data, 'must match')
    errors.add(:data_confirmation, 'must match')
  end

  def validate_own_email
    return unless data == user.email

    errors.add(:data, 'cannot be shared to yourself')
    errors.add(:data_confirmation, 'cannot be shared to yourself')
  end

  def find_recipient
    @find_recipient ||= User.find_by(email: data)
  end

  def set_recipient
    self.recipient = find_recipient
  end

  def notify_recipient
    RequestMailer.notify(id).deliver_later
  end

  def set_type
    return self.request_type = TYPES[:registered] if find_recipient.present?

    self.request_type = TYPES[:not_registered]
  end
end
