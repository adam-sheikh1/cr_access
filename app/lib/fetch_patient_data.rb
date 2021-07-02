class FetchPatientData
  class << self
    VAULT_URL = ENV.fetch('VAULT_URL').freeze

    def fetch_details(token)
      FilterPatientData.new(fetch_vaccinations(token))
    end

    def list_patients(ids)
      return [] if ids.blank?

      filter_patients(ids: ids)[:data]&.map do |params|
        {
          params[:id].to_s => FilterPatientData.new(params)
        }
      end&.reduce(&:merge) || {}
    end

    def assign_cr_data_attributes(cr_data_list)
      params = list_patients(cr_data_list.map(&:external_id))
      cr_data_list.each do |cr_data|
        cr_data.assign_attributes(params[cr_data.external_id].patient_list_params) if params[cr_data.external_id]
      end
    end

    def find_patient(first_name, last_name, email)
      FilterPatientData.new(filter_patients(first_name: first_name, last_name: last_name, email: email)[:data]&.first)
    end

    private

    def filter_patients(ids: [], first_name: nil, last_name: nil, email: nil)
      HTTParty.get(
        "#{VAULT_URL}/api/v1/patients",
        query: {
          filter: {
            id: (ids.is_a?(String) ? ids : ids.join(',')).presence,
            first_name: first_name,
            last_name: last_name,
            email: email
          }.compact
        }
      ).parsed_response&.deep_symbolize_keys || {}
    end

    def fetch_vaccinations(token)
      HTTParty.get(
        "#{VAULT_URL}/api/v1/vaccination_records",
        headers: {
          'Content-Type' => 'application/vnd.api+json',
          'Accept' => 'application/vnd.api+json',
          'Authorization' => "Bearer #{token}"
        }
      ).parsed_response&.deep_symbolize_keys
    end
  end
end
