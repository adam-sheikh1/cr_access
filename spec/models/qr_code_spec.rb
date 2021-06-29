require "rails_helper"

RSpec.describe QrCode, type: :model do
  it "has a valid factory" do
    qr_code = build(:qr_code)
    expect(qr_code).to be_valid
  end

  it "has a valid factory when codeable is cr group" do
    qr_code = build(:qr_code, :with_cr_group)
    expect(qr_code).to be_valid
  end

  it "has a valid factory when codeable is cr access data" do
    qr_code = build(:qr_code, :with_cr_access_data)
    expect(qr_code).to be_valid
  end
end
