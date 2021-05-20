class ImportPatientData
  VACCINATION_STATUSES = CrAccessData::VACCINATION_STATUSES

  def initialize(token)
    @token = token
    @response_hash = import
  end

  def patient_params
    @patient_params ||= filtered_params.merge(
      {
        primary: true,
        prepmod_patient_id: patient_attributes[:token],
        vaccination_status: vaccination_status
      }
    )
  rescue StandardError
    {}
  end

  def user_params
    patient_params.slice(*user_params_list)
  end

  def vaccination_status
    vaccination_status = vaccination_status_for(MODERNA)
    vaccination_status = vaccination_status_for(PFIZER) if vaccination_status_for(PFIZER).present?
    vaccination_status = vaccination_status_for(JANSSEN) if vaccination_status_for(JANSSEN).present?
    vaccination_status
  end

  def vaccination_params
    return [] if response_hash.blank?

    response_hash[:data].map do |data|
      data[:attributes].transform_keys do |key|
        next key unless key == :id

        :external_id
      end
    end
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

  def patient_attributes
    @patient_attributes ||= response_hash[:included].reduce(&:merge)[:attributes]
  end

  def patient_params_list
    %i[first_name last_name date_of_birth phone_number email address city state zip_code gender vaccination_status]
  end

  def user_params_list
    %i[email first_name last_name date_of_birth phone_number]
  end

  def import
    HTTParty.get(
      'https://cw2-passport.herokuapp.com/api/v1/vaccination_records',
      headers: {
        'Content-Type' => 'application/vnd.api+json',
        'Accept' => 'application/vnd.api+json',
        'Authorization' => "Bearer #{token}"
      }
    ).parsed_response&.deep_symbolize_keys
  end

  def vaccination_status_for(vaccine_name)
    vaccines = filter_vaccines(vaccine_name)

    if vaccines.count.zero?
      return VACCINATION_STATUSES[:not_vaccinated] if vaccine_name == MODERNA
      return
    end

    return VACCINATION_STATUSES[:fully_vaccinated] if is_valid_vaccination_interval?(vaccines, vaccine_name)
    VACCINATION_STATUSES[:partially_vaccinated]
  end

  def is_valid_vaccination_interval?(vaccines, vaccine_name)
    vaccination_dates = if vaccine_name == JANSSEN
                          vaccines.map{|v| v.dig(:attributes, :vaccination_date)}.first
                        else
                          vaccines.map{|v| v.dig(:attributes, :vaccination_date)}.first(2)
                        end

    valid_interval = Integer(DateTime.now - (DateTime.parse(vaccination_dates.last))) >= 10
    return valid_interval if vaccine_name == JANSSEN

    vaccination_interval = vaccine_name == PFIZER ? 21 : 28
    valid_interval && (Integer(DateTime.parse(vaccination_dates.last) - DateTime.parse(vaccination_dates.first)) >= vaccination_interval)
  end
end
