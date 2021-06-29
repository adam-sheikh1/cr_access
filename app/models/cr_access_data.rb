class CrAccessData < ApplicationRecord
  include QrCodeable
  include Encodable

  attr_accessor :primary, :setter_errors

  has_one_attached :profile_picture

  has_one :primary_data, -> { where(primary: true) }, class_name: 'CrDataUser'
  has_one :prepmod_data, -> { prepmod }, class_name: 'CrDataUser'
  has_one :user, through: :primary_data
  has_one :prepmod_user, through: :prepmod_data, source: :user
  has_one :fv_code, as: :fv_codable, dependent: :destroy

  has_many :cr_data_users, dependent: :destroy
  has_many :users, through: :cr_data_users
  has_many :cr_access_groups, dependent: :destroy
  has_many :cr_groups, through: :cr_access_groups
  has_many :accepted_access_groups, -> { accepted }, class_name: 'CrAccessGroup'
  has_many :accepted_cr_groups, through: :accepted_access_groups, class_name: 'CrGroup', source: :cr_group
  has_many :vaccination_records, dependent: :destroy

  validate :validate_no_setter_errors
  validates :profile_picture, blob: { content_type: %w[image/jpg image/jpeg image/png], size_range: 0..3.megabytes }

  after_save :set_fv_code
  after_create :fetch_vaccination_history

  VACCINATION_STATUSES = {
    not_vaccinated: 'not_vaccinated',
    partially_vaccinated: 'partially_vaccinated',
    fully_vaccinated: 'fully_vaccinated',
  }.freeze

  TTL = 1.week.to_i.freeze

  enum vaccination_status: VACCINATION_STATUSES

  def self.permitted_params_list
    %i[id encoded_attributes profile_picture]
  end

  def self.permitted_params
    permitted_params_list
  end

  def self.second_dose_reminder
    where('second_dose_reminder_date IS NOT NULL AND reminder_sent_at IS NULL AND second_dose_reminder_date = ? ', Date.today)
  end

  def gender=(sex)
    downcased_gender = sex.to_s.downcase

    self[:gender] = 'male' and return if downcased_gender == 'm'
    self[:gender] = 'female' and return if downcased_gender == 'f'
    self[:gender] = 'other' and return if downcased_gender == 'o'

    self[:gender] = sex
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def encoded_attributes
    encoded_token(payload: attributes.except('id', 'created_at', 'updated_at').merge({ primary: primary }))
  end

  def encoded_attributes=(attributes)
    @setter_errors ||= {}
    @setter_errors[:attributes] ||= []

    data = self.class.decoded_data(attributes)&.except('exp')
    if data.blank?
      @setter_errors[:attributes] << 'data is invalid/tempered'
      return
    end

    assign_attributes(data)
  end

  def validate_no_setter_errors
    return if setter_errors.blank?

    setter_errors.each do |attribute, messages|
      messages.each do |message|
        errors.add(attribute, message)
      end
    end

    setter_errors.empty?
  end

  def covidreadi_id=(_token); end

  def self.by_user(user)
    where(id: user.cr_access_data).or(where(id: user.accessible_cr_data))
  end

  def share_data(user)
    return false if user.all_cr_datum_ids.include?(id)

    CrDataUser.find_or_create_by(user: user, cr_access_data: self, data_type: CrDataUser::DATA_TYPES[:invited]).send_invitation(user.id)
  end

  def fetch_vaccination_history(data = nil)
    import_data = data.presence || ImportPatientData.new(prepmod_patient_id)
    update(vaccination_status: import_data&.vaccination_status)
    import_data&.vaccination_params&.each do |params|
      history = vaccination_records.find_or_initialize_by(external_id: params[:external_id])
      next if history.persisted?

      history.update(params.slice(*history.attributes.keys.map(&:to_sym)))
    end
  end

  def janssen_doses
    filtered_vaccinations(JANSSEN)
  end

  def pfizer_doses
    filtered_vaccinations(PFIZER)
  end

  def moderna_doses
    filtered_vaccinations(MODERNA)
  end

  def filtered_vaccinations(name)
    vaccination_records.select { |record| record.vaccine_name.downcase.include?(name) }&.sort_by(&:vaccination_date) || []
  end

  def covid_vaccines
    @covid_vaccines ||= janssen_doses.presence || pfizer_doses.presence || moderna_doses
  end

  def covid_vaccine_name
    return JANSSEN if janssen_doses.present?
    return MODERNA if moderna_doses.present?

    PFIZER if pfizer_doses.present?
  end

  def pfizer?
    pfizer_doses.present?
  end

  def moderna?
    moderna_doses.present?
  end

  def recommended_weeks
    return PFIZER_RECOMMENDED_WEEKS if pfizer?

    MODERNA_RECOMMENDED_WEEKS
  end

  private

  def set_fv_code
    return if fv_code.present?

    create_fv_code
  end
end
