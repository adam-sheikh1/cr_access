require "rails_helper"

RSpec.describe CrGroup, type: :model do
  it "has a valid factory" do
    cr_group = build(:cr_group)
    expect(cr_group).to be_valid
  end
end
