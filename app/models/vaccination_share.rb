class VaccinationShare
  include ActiveModel::Model

  attr_accessor :data, :data_confirmation, :cr_access_no, :current_user, :relation_ship

  validate :valid_data, :validate_own_email, :valid_user, if: -> { data.present? && data_confirmation.present? }
  validate :validate_cr_no, if: -> { cr_access_no.present? }
  validate :valid_relationship, if: -> { relation_ship.present? }
  validates_presence_of :data, :data_confirmation

  RELATION_SHIPS = {
    father: 'father',
    mother: 'mother',
    child: 'child'
  }.freeze

  def self.init(params, current_user)
    vaccinations = []
    params.each do |p|
      vaccination = new(p)
      vaccination.current_user = current_user
      vaccinations << vaccination
    end

    vaccinations
  end

  def self.valid?(records)
    records.map(&:valid?).all?(&:present?)
  end

  def self.share(records, ids)
    records.each do |record|
      record.share(ids)
    end
  end

  def share(ids)
    time = DateTime.now
    records = (ids - user.accessible_vaccination_ids).map do |id|
      {
        relation_ship: relation_ship,
        user_id: user.id,
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

  def valid_user
    return unless user.blank?

    errors.add(:data, 'is invalid')
    errors.add(:data_confirmation, 'is invalid')
  end

  def validate_cr_no
    return unless user_by_cr_no.blank?

    errors.add(:cr_access_no, 'is invalid')
  end

  def validate_own_email
    return unless data == current_user.email

    errors.add(:data, 'cannot be shared to yourself')
    errors.add(:data_confirmation, 'cannot be shared to yourself')
  end

  def user
    @user ||= User.find_by(email: data) || User.find_by(phone_number: data) || user_by_cr_no
  end

  def user_by_cr_no
    @fv_user ||= FvCode.cr_access.find_by(code: cr_access_no)&.fv_codable&.user
    return if @fv_user.blank?
    return unless @fv_user.email == data || @fv_user.phone_number == data

    @fv_user
  end

  def valid_relationship
    return if relation_ship.in?(RELATION_SHIPS.values)

    errors.add(:relation_ship, 'is invalid')
  end
end
