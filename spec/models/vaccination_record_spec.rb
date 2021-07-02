require 'rails_helper'

RSpec.describe VaccinationRecord, type: :model do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  it 'has a valid factory' do
    vaccination_record = build(:vaccination_record)
    expect(vaccination_record).to be_valid
  end

  describe 'self.by_cr_access_data' do
    it 'returns a list of vaccine for a given cr access data' do
      stub_request(:get, /vault/)
        .to_return(status: 200, body: File.read('spec/responses/vaccine_info_response.json'), headers: { 'Content-Type' => 'application/json' })
      cr_access_data = create(:cr_access_data)
      expect(VaccinationRecord.by_cr_access_data(cr_access_data).size).to eql 2
      expect(VaccinationRecord.by_cr_access_data(cr_access_data).map(&:vaccine_name).sort).to eql %w[Pfizer1 Pfizer2]
    end
  end

  describe 'vaccination_date' do
    it 'should set valid date' do
      stub_request(:get, /vault/)
      vaccinations_record = create(:vaccination_record)
      vaccinations_record.vaccination_date = 'Invalid Date'
      expect(vaccinations_record.vaccination_date).to eql nil
      vaccinations_record.vaccination_date = '07-02-2021'
      expect(vaccinations_record.vaccination_date).to eql '07-02-2021'.to_date
      vaccinations_record.vaccination_date = '07-02-2021'.to_date
      expect(vaccinations_record.vaccination_date).to eql '07-02-2021'.to_date
    end
  end
end
