require "rails_helper"

RSpec.describe CrDataUser, type: :model do
  it "has a valid factory" do
    cr_data_user = build(:cr_data_user)
    expect(cr_data_user).to be_valid
  end
end
