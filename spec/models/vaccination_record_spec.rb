require "rails_helper"

RSpec.describe VaccinationRecord, type: :model do
  it "has a valid factory" do
    vaccination_record = create(:vaccination_record, :with_cr_access_data, :with_vaccination_users)
    expect(vaccination_record.valid?).to be true
  end
end
