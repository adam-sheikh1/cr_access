require "rails_helper"

RSpec.describe CrAccessGroup, type: :model do
  it "has a valid factory" do
    cr_access_group = build(:cr_access_group)
    expect(cr_access_group).to be_valid
  end
end
