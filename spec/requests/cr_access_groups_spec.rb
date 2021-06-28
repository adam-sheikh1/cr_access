require 'rails_helper'

RSpec.describe "CrAccessGroups", type: :request do
  describe "GET #accept invite" do
    context 'when cr access group blank' do
      it "redirects to root path" do
        get accept_invite_cr_access_groups_path

        expect(response).to redirect_to root_path
      end
    end

    context 'when cr access group present' do
      it "fetches the correct record" do
        cr_access_group = create(:cr_access_group)
        get accept_invite_cr_access_groups_path(token: cr_access_group.invitation_token)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Accept Group Invitation")
      end
    end
  end

  describe "PATCH #process_invite" do
    context 'when cr access group blank' do
      it "redirects to root path" do
        patch process_invite_cr_access_group_path(0)

        expect(response).to redirect_to root_path
      end
    end

    context 'when cr access group present' do
      it "updates the record" do
        cr_access_group = create(:cr_access_group)
        cr_access_group.anyone!
        patch process_invite_cr_access_group_path(cr_access_group), params: { cr_access_group: { access_level: 'owner' } }

        expect(cr_access_group.reload.access_level).to eql 'owner'
      end
    end
  end
end
