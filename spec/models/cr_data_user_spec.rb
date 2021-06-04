require "rails_helper"

RSpec.describe CrDataUser, type: :model do
  it "has a valid factory" do
    cr_data_user = create(:cr_data_user, :with_cr_access_data, user: create(:user))
    expect(cr_data_user.valid?).to be true
  end
end
