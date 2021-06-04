require "rails_helper"

RSpec.describe CrGroup, type: :model do
  it "has a valid factory" do
    cr_group = create(:cr_group, user: create(:user))
    expect(cr_group.valid?).to be true
  end
end
