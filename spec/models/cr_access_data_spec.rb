require "rails_helper"

RSpec.describe CrAccessData, type: :model do
  it "has a valid factory" do
    cr_access_data = build(:cr_access_data)
    expect(cr_access_data).to be_valid
  end
end
