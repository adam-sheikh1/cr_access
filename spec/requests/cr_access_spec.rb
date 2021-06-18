require 'rails_helper'

RSpec.describe "CrAccess", type: :request do
  let(:user) { create(:user) }
  let(:cr_access_data) { create(:cr_access_data, :profile_picture) }
  let(:cr_data_user) { create(:cr_data_user, :with_cr_access_data) }

  describe "POST #create" do
    context 'valid user' do
      it "inserts row in table" do
        user.cr_access_data << cr_access_data
        post cr_access_index_path, params: { user: user.attributes.except("id").
            merge({ cr_access_data_attributes: cr_access_data.encoded_attributes })}

        expect(response).to be_redirect
      end
    end

    context 'invalid user' do
      it "does not insert new row" do
        post cr_access_index_path, params: { user: user.attributes.except("id").merge('first_name' => '')}

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

  describe "GET #show" do
    context 'vhen signed in' do
      context 'when cr data user blank' do
        it "redirect to root path and raise invalid access error" do
          sign_in user
          get cr_access_path(user)

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr access data blank' do
        it "redirect to root path and raise invalid access error" do
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          cr_data_user.cr_access_data.destroy
          user.cr_data_users << cr_data_user
          get cr_access_path(cr_data_user)

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr data user and cr access data present' do
        it "display show page" do
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          user.cr_data_users << cr_data_user
          get cr_access_path(cr_data_user)

          expect(response.body).to include("Info")
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get cr_access_path(user)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #unlink" do
    context 'vhen signed in' do
      context 'when cr data user blank' do
        it "redirect to root path and raise invalid access error" do
          sign_in user
          delete unlink_cr_access_path(user)

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr access data blank' do
        it "redirect to root path and raise invalid access error" do
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          cr_data_user.cr_access_data.destroy
          user.cr_data_users << cr_data_user
          delete unlink_cr_access_path(cr_data_user)

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr data user and cr access data present' do
        it "unlink cr access" do
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          user.cr_data_users << cr_data_user
          delete unlink_cr_access_path(cr_data_user)

          expect(flash[:notice]).to match(/Successfully unlinked.*/)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get cr_access_path(user)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update profile picture" do
    context 'vhen signed in' do
      context 'when cr data user blank' do
        it "redirect to root path and raise invalid access error" do
          sign_in user
          patch update_profile_picture_cr_access_path(cr_access_data)

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr access data blank' do
        it "redirect to root path and raise invalid access error" do
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          cr_data_user.cr_access_data.destroy
          user.cr_data_users << cr_data_user
          patch update_profile_picture_cr_access_path(cr_access_data)

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr data user and cr access data present' do
        it "updates profile picture" do
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          user.cr_data_users << cr_data_user
          patch update_profile_picture_cr_access_path(cr_data_user),
                params: { cr_access_data: { profile_picture: Rack::Test::UploadedFile.new('spec/assets/login-logo.png', 'image/png') } },
                headers: { "HTTP_REFERER": "http://example.com" }

          expect(flash[:notice]).to match(/Successfully updated profile picture*/)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        patch update_profile_picture_cr_access_path(cr_access_data)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
