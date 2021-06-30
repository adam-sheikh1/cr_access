require 'rails_helper'

RSpec.describe "QrCodes", type: :request do
  describe "GET #verify" do
    context 'when qr code blank' do
      it "displays verify page" do
        get verify_qr_codes_path

        expect(response.body).to include("QR Code is Invalid/Expired")
        expect(response).to be_successful
      end
    end

    context 'when qr code present' do
      around do |example|
        with_modified_env(VAULT_URL: "https://vault.com", &example)
      end

      context 'qr code with cr access data as codeable' do
        it "display verify page" do
          stub_request(:get, /vault/)
          qr_code_with_cr_access_data = create(:qr_code, :with_cr_access_data)
          get verify_qr_codes_path, params: { code: qr_code_with_cr_access_data.code }

          expect(response.body).to include("Welcome, #{qr_code_with_cr_access_data.codeable.full_name}!")
          expect(response).to be_successful
        end
      end

      context 'qr code with cr access group as codeable' do
        it "display verify page" do
          qr_code_with_cr_group =  create(:qr_code, :with_cr_group )
          get verify_qr_codes_path, params: { code: qr_code_with_cr_group.code }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET #refreshed code" do
    around do |example|
      with_modified_env(VAULT_URL: "https://vault.com", &example)
    end

    context 'when signed in' do
      it "refreshes the code" do
        stub_request(:get, /vault/)
        user = create(:user)
        qr_code_with_cr_access_data = create(:qr_code, :with_cr_access_data)
        sign_in user
        get refreshed_code_qr_code_path(qr_code_with_cr_access_data)

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        stub_request(:get, /vault/)
        qr_code_with_cr_access_data = create(:qr_code, :with_cr_access_data)
        get refreshed_code_qr_code_path(qr_code_with_cr_access_data)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
