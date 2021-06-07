require 'rails_helper'

RSpec.describe "SharedRecords", type: :request do
  let(:user) { create(:user) }
  let(:cr_access_group) { create(:cr_access_group, :with_cr_access_data, :with_cr_group) }

  describe "GET #show" do
    context 'when signed in' do
      context 'when cr access group blank' do
        it "redirects to user vaccination path" do
          sign_in user
          get shared_record_path(cr_access_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end

      context 'when cr access group present' do
        it "fetches the correct record" do
          sign_in user
          cr_access_group.accepted!
          user.all_cr_data << cr_access_group.cr_access_data
          get shared_record_path(cr_access_group)

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Vaccination History")
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get shared_record_path(cr_access_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
