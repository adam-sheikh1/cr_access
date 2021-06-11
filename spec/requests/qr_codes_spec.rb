require 'rails_helper'

RSpec.describe "QrCodes", type: :request do
  let(:user) { create(:user) }
  let(:qr_code_with_cr_access_data) { create(:qr_code, :with_cr_access_data) }
  let(:qr_code_with_cr_group ) { create(:qr_code, :with_cr_group ) }

  describe "GET #verify" do
    context 'when qr code blank' do
      it "display verify page" do
        get verify_qr_codes_path

        expect(response.body).to include("QR Code is Invalid/Expired")
      end
    end

    context 'when qr code present' do
      context 'qr code with cr access data as codeable' do
        it "display verify page" do
          get verify_qr_codes_path, params: { code: qr_code_with_cr_access_data.code }

          expect(response.body).to include("Welcome, #{qr_code_with_cr_access_data.codeable.full_name}!")
        end
      end

      context 'qr code with cr access group as codeable' do
        it "display verify page" do
          get verify_qr_codes_path, params: { code: qr_code_with_cr_group.code }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET #refreshed code" do
    context 'when signed in' do
      it "refreshes the code" do
        sign_in user
        get refreshed_code_qr_code_path(qr_code_with_cr_access_data)

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get refreshed_code_qr_code_path(qr_code_with_cr_access_data)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
