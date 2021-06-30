require "rails_helper"

RSpec.describe "Shared Request", type: :request do

  describe "#index" do
    it "lists all the requests" do
      user = create(:user)
      sign_in user
      user1, user2, user3 = create_list(:user, 3)
      create(:share_request, data: user.email, user: user1)
      create(:share_request, data: user.email, user: user2)
      create(:share_request, data: user.email, user: user3)

      get shared_requests_path

      expect(response).to be_successful
      expect(response.body).to include(user1.email)
      expect(response.body).to include(user2.email)
      expect(response.body).to include(user3.email)
    end
  end
end
