require "rails_helper"

RSpec.describe QrCode, type: :model do
  it "has a valid factory" do
    qr_code = build(:qr_code)
    expect(qr_code).to be_valid
  end
end
