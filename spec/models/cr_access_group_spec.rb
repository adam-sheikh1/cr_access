require "rails_helper"

RSpec.describe CrAccessGroup, type: :model do
  it "has a valid factory" do
    cr_access_group = create(:cr_access_group, :with_cr_access_data, :with_cr_group)
    expect(cr_access_group.valid?).to be true
  end
end
