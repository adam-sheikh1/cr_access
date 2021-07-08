class FilterPatientData
  VACCINATION_STATUSES = CrAccessData::VACCINATION_STATUSES
  FULLY_VACCINATE_INTERVAL = 10
  PFIZER_INTERVAL = 21
  MODERNA_INTERVAL = 28
  SECOND_DOSE_REMINDER_OFFSET = 10
  JANSSEN_DOSES = 1
  OTHER_DOSES = 2

  def initialize(response_hash)
    @response_hash = response_hash
  end

  def patient_params
    @patient_params ||= filtered_params.merge(
      {
        primary: true,
        prepmod_patient_id: patient_attributes[:token],
        vaccination_status: vaccination_status,
        second_dose_reminder_date: second_dose_reminder_date,
        second_dose_date: second_dose_date,
        external_id: patient_attributes[:id]
      }
    )
  rescue StandardError
    {}
  end

  def dependent_params
    filtered_dependents.map do |dependent|
      {
        primary: false,
        external_id: dependent[:id],
        first_name: dependent[:first_name],
        last_name: dependent[:last_name],
        prepmod_patient_id: dependent[:token]
      }
    end
  end

  def parent_params
    (child? ? filtered_parent : patient_params)
  end

  def patient_list_params
    filtered_list_params
  end

  def user_params
    (child? ? filtered_parent : patient_params).slice(*user_params_list)
  end

  def vaccination_status
    return vaccination_status_for(JANSSEN) if janssen?
    return vaccination_status_for(MODERNA) if moderna?
    return vaccination_status_for(PFIZER) if pfizer?

    VACCINATION_STATUSES[:not_vaccinated]
  end

  def vaccination_params
    return [] if response_hash.blank?

    response_hash[:data].map do |data|
      data[:attributes].transform_keys do |key|
        next key unless key.to_s == 'id'

        :external_id
      end
    end
  end

  def patient_id
    return if response_hash.blank?

    response_hash[:id]
  end

  private

  attr_accessor :token, :response_hash

  def vaccine_count
    vaccines_administered.count
  end

  def vaccines_administered
    filter_vaccines(PFIZER).presence || filter_vaccines(MODERNA)
  end

  def filter_vaccines(name)
    return [] if response_hash.blank?

    response_hash[:data].select do |vaccine_administered|
      vaccine_administered[:attributes][:vaccine_name].to_s.downcase.include?(name)
    end
  end

  def filtered_params
    patient_attributes.slice(*patient_params_list)
  end

  def filtered_dependents
    response_hash[:included].first.dig(:attributes, :dependents) || []
  end

  def filtered_parent
    response_hash[:included].first.dig(:relationships, :parent, :data) || {}
  end

  def filtered_list_params
    response_hash[:attributes].slice(*patient_params_list)
  end

  def patient_attributes
    @patient_attributes ||= response_hash[:included].reduce(&:merge)[:attributes]
  end

  def patient_params_list
    %i[first_name last_name date_of_birth phone_number email address city state zip_code gender vaccination_status]
  end

  def user_params_list
    %i[email first_name last_name date_of_birth phone_number]
  end

  def vaccination_status_for(vaccine_name)
    vaccines = filter_vaccines(vaccine_name)
    return VACCINATION_STATUSES[:fully_vaccinated] if valid_interval?(vaccines, vaccine_name)

    VACCINATION_STATUSES[:partially_vaccinated]
  end

  def valid_interval?(vaccines, vaccine_name)
    vaccination_dates = vaccination_dates(vaccines).first(vaccine_name == JANSSEN ? JANSSEN_DOSES : OTHER_DOSES).reject(&:blank?)
    return false if vaccination_dates.blank?

    valid_interval = (DateTime.now - DateTime.parse(vaccination_dates.last)).to_i.abs >= FULLY_VACCINATE_INTERVAL
    return valid_interval if vaccine_name == JANSSEN

    vaccination_interval = vaccine_name == PFIZER ? PFIZER_INTERVAL : MODERNA_INTERVAL
    valid_interval && ((DateTime.parse(vaccination_dates.last) - DateTime.parse(vaccination_dates.first)).to_i.abs >= vaccination_interval)
  end

  def vaccination_dates(vaccines)
    vaccines.map do |v|
      v.dig(:attributes, :vaccination_date)
    end
  end

  def second_dose_reminder_date
    date = second_dose_date
    return if date.blank?

    date - SECOND_DOSE_REMINDER_OFFSET.days
  end

  def second_dose_date
    return if janssen?
    return if vaccine_count > 1

    vaccine = vaccines_administered.first&.dig(:attributes)
    return if vaccine.blank?

    date = vaccine[:vaccination_date].to_date rescue nil
    return if date.blank?

    if vaccine[:vaccine_name].downcase.include?(PFIZER)
      date + PFIZER_INTERVAL.days
    else
      date + MODERNA_INTERVAL.days
    end
  end

  def janssen?
    filter_vaccines(JANSSEN).present?
  end

  def moderna?
    filter_vaccines(MODERNA).present?
  end

  def pfizer?
    filter_vaccines(PFIZER).present?
  end

  def child?
    return false if response_hash.blank?

    response_hash[:included].first[:relationships].keys.include?('parent')
  end
end
