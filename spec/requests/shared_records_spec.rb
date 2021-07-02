require 'rails_helper'

RSpec.describe "SharedRecords", type: :request do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  describe "GET #show" do
    context 'when signed in' do
      context 'when cr access group blank' do
        it "redirects to user vaccination path" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_access_group = create(:cr_access_group)
          sign_in user
          get shared_record_path(cr_access_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end

      context 'when cr access group present' do
        it "fetches the correct record and displays the show page" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_access_group = create(:cr_access_group)
          sign_in user
          cr_access_group.accepted!
          user.all_cr_data << cr_access_group.cr_access_data
          get shared_record_path(cr_access_group)

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Vaccination History")
        end

        it "fetches the correct vaccination record list" do
          stub_request(:get, /vault/)
            .to_return(status: 200, body: File.read('spec/responses/vaccine_info_response.json'), headers: { 'Content-Type' => 'application/json' })
          user = create(:user)
          cr_access_group = create(:cr_access_group)

          sign_in user
          cr_access_group.accepted!
          user.all_cr_data << cr_access_group.cr_access_data
          new_vaccination_records = cr_access_group.cr_access_data.vaccination_records_accessor
          get shared_record_path(cr_access_group)

          expect(response).to have_http_status(:success)

          new_vaccination_records.each do |vr|
            expect(response.body).to include(vr.lot_number)
          end
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        stub_request(:get, /vault/)
        cr_access_group = create(:cr_access_group)
        get shared_record_path(cr_access_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
