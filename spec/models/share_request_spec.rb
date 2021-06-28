require 'rails_helper'

RSpec.describe ShareRequest, type: :model do
  it 'has a valid factory' do
    share_request = create(:share_request, :public_share)
    expect(share_request).to be_valid

    share_request = create(:share_request, :registered_share)
    expect(share_request).to be_valid
  end
end
