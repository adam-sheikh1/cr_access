require "rails_helper"

RSpec.describe VaccinationRecord, type: :model do
  it "has a valid factory" do
    vaccination_record = build(:vaccination_record)
    expect(vaccination_record).to be_valid
  end
end
