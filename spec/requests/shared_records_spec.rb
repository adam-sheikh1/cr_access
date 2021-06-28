require 'rails_helper'

RSpec.describe "SharedRecords", type: :request do
  describe "GET #show" do
    context 'when signed in' do
      context 'when cr access group blank' do
        it "redirects to user vaccination path" do
          user = create(:user)
          cr_access_group = create(:cr_access_group)
          sign_in user
          get shared_record_path(cr_access_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end

      context 'when cr access group present' do
        it "fetches the correct record and displays the show page" do
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
          user = create(:user)
          cr_access_group = create(:cr_access_group)
          vaccination_records = create_list(:vaccination_record, 2, :with_vaccination_users)
          other_vaccination_record = create(:vaccination_record, :with_vaccination_users)

          sign_in user
          cr_access_group.accepted!
          user.all_cr_data << cr_access_group.cr_access_data
          new_vaccination_records = cr_access_group.cr_access_data.vaccination_records << vaccination_records
          get shared_record_path(cr_access_group)

          expect(response).to have_http_status(:success)

          new_vaccination_records.each do |vr|
            expect(response.body).to include(vr.lot_number)
          end

          expect(response.body).to_not include(other_vaccination_record.lot_number)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        cr_access_group = create(:cr_access_group)
        get shared_record_path(cr_access_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
