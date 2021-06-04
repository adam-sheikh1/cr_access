require "rails_helper"

RSpec.describe QrCode, type: :model do
  it "has a valid factory when " do
    qr_code = create(:qr_code)
    expect(qr_code.valid?).to be true
  end
end
