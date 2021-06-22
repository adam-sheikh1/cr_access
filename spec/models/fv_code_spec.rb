require "rails_helper"

RSpec.describe FvCode, type: :model do
  it "has a valid factory" do
    fv_code = build(:fv_code)
    expect(fv_code).to be_valid
  end
end
