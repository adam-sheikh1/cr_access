require "rails_helper"

RSpec.describe ShareRequest, type: :model do
  it "has a valid factory" do
    share_request = build(:share_request)
    expect(share_request).to be_valid

    share_request = build(:share_request, :public_share)
    expect(share_request).to be_valid

    share_request = build(:share_request, :registered_share)
    expect(share_request).to be_valid
  end
end
