class ShareRequest < ApplicationRecord
  belongs_to :user
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id', optional: true

  attr_accessor :data_confirmation

  validate :valid_data, if: -> { data_confirmation.present? }
  validate :validate_own_email, :validate_recipient

  validates_presence_of :data

  before_save :set_recipient

  RELATION_SHIPS = {
    father: 'father',
    mother: 'mother',
    child: 'child'
  }.freeze

  STATUSES = {
    pending: 'pending',
    accepted: 'accepted'
  }.freeze

  TYPES = {
    user: 'user',
    email: 'email'
  }.freeze

  enum status: STATUSES
  enum request_type: TYPES
  enum relationship: RELATION_SHIPS

  def vaccination_records
    VaccinationRecord.where(id: vaccination_record_ids)
  end

  def mark_accepted
    return if accepted?

    accepted!
    recipient.accessible_vaccinations << vaccination_records.where.not(id: recipient.accessible_vaccination_ids)
    recipient.update(two_fa_code: nil, accepted_at: DateTime.now)
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

  def validate_recipient
    return unless find_recipient.blank?

    errors.add(:data, 'is invalid')
    errors.add(:data_confirmation, 'is invalid')
  end

  def find_recipient
    @find_recipient ||= User.find_by(email: data) || User.find_by(phone_number: data)
  end

  def set_recipient
    self.recipient = find_recipient
  end
end
