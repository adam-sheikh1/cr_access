require "rails_helper"

RSpec.describe VaccinationUser, type: :model do
  it "has a valid factory" do
    vaccination_user = create(:vaccination_user, :with_vaccination_record, user: create(:user))
    expect(vaccination_user.valid?).to be true
  end
end
