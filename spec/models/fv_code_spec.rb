require "rails_helper"

RSpec.describe FvCode, type: :model do
  it "has a valid factory when " do
    fv_code = create(:fv_code)
    expect(fv_code.valid?).to be true
  end
end
