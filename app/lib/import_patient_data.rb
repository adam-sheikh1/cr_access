class ImportPatientData
  attr_accessor :token, :response_hash

  VACCINATION_STATUSES = CrAccessData::VACCINATION_STATUSES

  def initialize(token)
    @token = token
    @response_hash = import
  end

  def patient_params
    @patient_params ||= filtered_params.merge(
      {
        'primary' => true,
        'prepmod_patient_id' => patient_attributes['token'],
        'vaccination_status' => vaccination_status
      }
    )
  rescue StandardError
    {}
  end

  private

  def vaccination_status
    return VACCINATION_STATUSES[:not_vaccinated] if response_hash['data'].blank?
    return VACCINATION_STATUSES[:fully_vaccinated] if vaccine_count > 1

    VACCINATION_STATUSES[:partially_vaccinated]
  end

  def vaccine_count
    vaccines_administered.count
  end

  def vaccines_administered
    filter_vaccines('Pfizer').presence || filter_vaccines('Moderna')
  end

  def filter_vaccines(name)
    response_hash['data'].select do |vaccine_administered|
      vaccine_administered['attributes']['vaccine_name'].include?(name)
    end
  end

  def filtered_params
    patient_attributes.slice(*slice_param_list)
  end

  def patient_attributes
    response_hash['included'].reduce(&:merge)['attributes']
  end

  def slice_param_list
    %w[first_name last_name date_of_birth phone_number email address city state zip_code gender vaccination_status]
  end

  def import
    HTTParty.get(
      'https://cw2-passport.herokuapp.com/api/v1/vaccination_records',
      headers: {
        'Content-Type' => 'application/vnd.api+json',
        'Accept' => 'application/vnd.api+json',
        'Authorization' => "Bearer #{token}",
      }
    ).parsed_response
  end
end
