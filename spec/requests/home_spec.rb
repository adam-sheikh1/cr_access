require 'rails_helper'

RSpec.describe "Home", type: :request do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  describe "GET #index" do
    context 'when signed in' do
      it "display index page" do
        stub_request(:get, /vault/)
        user = create(:user)
        cr_data_user = create(:cr_data_user, user: user)
        sign_in user
        cr_data_user.update_column(:primary, true)
        get root_path

        expect(response.body).to include("Welcome #{user.full_name}")
        expect(response).to be_successful
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get root_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
