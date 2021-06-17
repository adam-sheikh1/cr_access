require 'rails_helper'

RSpec.describe "CrAccess", type: :request do
  let(:user) { create(:user) }
  let(:cr_access_data) { create(:cr_access_data, :profile_picture) }

  describe "POST #create" do
    context 'valid user' do
      it "inserts row in table" do
        user.cr_access_data << cr_access_data
        post cr_access_index_path, params: { user: user.attributes.except("id").
            merge({ cr_access_data_attributes: cr_access_data.encoded_attributes})}

        expect(response).to be_redirect
      end
    end

    context 'invalid user' do
      it "does not insert new row" do
        post cr_access_index_path, params: { user: user.attributes.except("id").merge('first_name' => '').
            merge({ cr_access_data_attributes: cr_access_data.encoded_attributes})}

        expect(response).not_to be_redirect
      end
    end
  end

  describe "PATCH #update" do
    context 'valid user' do
      it "updates record and redirect to root path" do
        patch cr_access_path(user), params: { user: user.attributes.merge('first_name' => 'test name') }

        expect(user.reload.first_name).to eql 'test name'
      end
    end

    context 'invalid user' do
      it "renders the edit page" do
        patch cr_access_path(user), params: { user: user.attributes.merge('first_name' => '') }

        expect(response).not_to be_redirect
      end
    end
  end

  describe "GET #success" do
    context 'when new record' do
      it "display success page" do
        user.cr_access_data << cr_access_data
        get success_cr_access_path(user), params: { new_record: true }

        expect(response.body).to include('An email has been sent to you.')
      end
    end

    context 'when old record' do
      it "display success page" do
        user.cr_access_data << cr_access_data
        get success_cr_access_path(user)

        expect(response.body).to include("You already have an account with the email #{user.email}, use that to login.")
      end
    end
  end
end
