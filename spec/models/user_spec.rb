require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    user = create(:user)
    expect(user.valid?).to be true
  end
end
