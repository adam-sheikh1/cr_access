require "rails_helper"

RSpec.describe CrAccessData, type: :model do
  it "has a valid factory" do
    cr_access_data = create(:cr_access_data)
    expect(cr_access_data.valid?).to be true
  end
end
