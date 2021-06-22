require "rails_helper"

RSpec.describe VaccinationUser, type: :model do
  it "has a valid factory" do
    vaccination_user = build(:vaccination_user)
    expect(vaccination_user).to be_valid
  end
end
