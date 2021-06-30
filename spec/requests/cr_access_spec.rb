require 'rails_helper'

RSpec.describe "CrAccess", type: :request do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  describe "GET #new" do
    context 'invalid access' do
      it "redirect to sign in path and raise invalid access error" do
        stub_request(:get, /vault/)
        get new_cr_access_path

        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to match(/Invalid Access*/)
      end
    end
  end

  describe "POST #create" do
    context 'valid user' do
      context 'when new record' do
        it "inserts row in table" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_access_data = create(:cr_access_data, :profile_picture)

          user.cr_access_data << cr_access_data

          expect { post cr_access_index_path, params: {
              user: user.attributes.merge('email' => Faker::Internet.email, password: 'password').except("id")
                    .merge({ cr_access_data_attributes: cr_access_data.encoded_attributes })} }.to change(User, :count).by(1)
          record = User.last

          expect(record.first_name).to eq user.first_name
          expect(response).to redirect_to success_cr_access_path(record, new_record: true)
        end
      end

      context 'when old record' do
        it "updates the record" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_access_data = create(:cr_access_data, :profile_picture)

          user.cr_access_data << cr_access_data

          expect { post cr_access_index_path, params: { user: user.attributes.except("id")
            .merge({ cr_access_data_attributes: cr_access_data.encoded_attributes })} }.to_not change(User, :count)

          expect(response).to redirect_to success_cr_access_path(user, new_record: false)
        end
      end
    end

    context 'invalid user' do
      it "does not insert new row" do
        user = create(:user)

        expect {
          post cr_access_index_path, params: { user: user.attributes.except("id").merge('first_name' => '')}
        }.to_not change(User, :count)
      end
    end
  end

  describe "PATCH #update" do
    context 'valid user' do
      it "updates record and redirect to root path" do
        user = create(:user)

        patch cr_access_path(user), params: { user: user.attributes.merge('first_name' => 'test name') }

        expect(user.reload.first_name).to eql 'test name'
      end
    end

    context 'invalid user' do
      it "renders the edit page" do
        user = create(:user)
        patch cr_access_path(user), params: { user: user.attributes.merge('first_name' => '') }

        expect(response).to be_successful
      end
    end
  end

  describe "GET #show" do
    context 'vhen signed in' do
      context 'when cr data user blank' do
        it "redirect to root path and raise invalid access error" do
          user = create(:user)
          sign_in user
          get cr_access_path(user)

          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr access data blank' do
        it "redirect to root path and raise invalid access error" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_data_user = create(:cr_data_user)
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
          stub_request(:get, /vault/)
          user = create(:user)
          cr_data_user = create(:cr_data_user)
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          user.cr_data_users << cr_data_user
          get cr_access_path(cr_data_user)

          expect(response.body).to include("Info")
          expect(response).to be_successful
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        get cr_access_path(user)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #unlink" do
    context 'vhen signed in' do
      context 'when cr data user blank' do
        it "redirect to root path and raise invalid access error" do
          user = create(:user)
          sign_in user

          expect{ delete unlink_cr_access_path(user) }.to_not change(CrDataUser, :count)
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr access data blank' do
        it "redirect to root path and raise invalid access error" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_data_user = create(:cr_data_user)
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          cr_data_user.cr_access_data.destroy
          user.cr_data_users << cr_data_user

          expect{ delete unlink_cr_access_path(user) }.to_not change(CrDataUser, :count)
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr data user and cr access data present' do
        it "unlink cr access" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_data_user = create(:cr_data_user)
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          user.cr_data_users << cr_data_user

          expect{ delete unlink_cr_access_path(cr_data_user) }.to change(CrDataUser, :count).by(-1)
          expect(flash[:notice]).to match(/Successfully unlinked.*/)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        get cr_access_path(user)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update profile picture" do
    context 'vhen signed in' do
      context 'when cr data user blank' do
        it "redirect to root path and raise invalid access error" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_access_data = create(:cr_access_data, :profile_picture)
          sign_in user

          expect { patch update_profile_picture_cr_access_path(cr_access_data) }.to_not change { cr_access_data.reload.attributes }
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr access data blank' do
        it "redirect to root path and raise invalid access error" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_access_data = create(:cr_access_data, :profile_picture)
          cr_data_user = create(:cr_data_user)
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          cr_data_user.cr_access_data.destroy
          user.cr_data_users << cr_data_user

          expect { patch update_profile_picture_cr_access_path(cr_access_data) }.to_not change { cr_access_data.reload.attributes }
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to match(/Invalid Access*/)
        end
      end

      context 'when cr data user and cr access data present' do
        it "updates profile picture" do
          stub_request(:get, /vault/)
          user = create(:user)
          cr_data_user = create(:cr_data_user)
          sign_in user
          cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
          user.cr_data_users << cr_data_user
          patch update_profile_picture_cr_access_path(cr_data_user),
                params: { cr_access_data: { profile_picture: Rack::Test::UploadedFile.new('spec/assets/login-logo.png', 'image/png') } },
                headers: { "HTTP_REFERER": "http://example.com" }

          expect(cr_data_user.cr_access_data.reload.profile_picture).to be_attached
          expect(flash[:notice]).to match(/Successfully updated profile picture*/)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        stub_request(:get, /vault/)
        cr_access_data = create(:cr_access_data, :profile_picture)
        patch update_profile_picture_cr_access_path(cr_access_data)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
