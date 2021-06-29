require "rails_helper"

RSpec.describe FvCode, type: :model do
  it "has a valid factory" do
    fv_code = build(:fv_code)
    expect(fv_code).to be_valid
  end

  it "has a valid factory when codeable is cr group" do
    fv_code = build(:fv_code, :with_cr_group)
    expect(fv_code).to be_valid
  end

  it "has a valid factory when codeable is cr access data" do
    fv_code = build(:fv_code, :with_cr_access_data)
    expect(fv_code).to be_valid
  end
end
