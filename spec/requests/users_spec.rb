require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let(:cr_group) { create(:cr_group) }
  let(:cr_data_user) { create(:cr_data_user, :with_cr_access_data) }
  let(:cr_access_data) { create(:cr_access_data) }

  describe "GET #show" do
    context 'when signed in' do
      context 'when cr access data not present' do
        it "displays the show page without cr access data info" do
          sign_in user
          get user_path(user)

          expect(response.body).to include("Welcome #{user.full_name}")
        end
      end

      context 'when cr access data present' do
        it "displays the show page with cr access data info" do
          sign_in user
          user.primary_cr_data = cr_access_data
          get user_path(user)

          expect(response.body).to include("Welcome #{user.full_name}")
          expect(response.body).to include(cr_access_data.full_name)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get user_path(user)

        expect(response.status).to eq 401
      end
    end
  end

  describe "GET #vaccinations" do
    context 'when signed in' do
      context 'when cr group and cr data user present' do
        it "displays the vaccinations page with cr group and cr data user info" do
          sign_in user
          user.cr_groups << cr_group
          user.cr_data_users << cr_data_user
          cr_data_user.accepted!
          get vaccinations_user_path

          expect(response.body).to include(cr_access_path(cr_data_user))
          expect(response.body).to include(cr_group_path(cr_group))
        end
      end

      context 'when cr group and cr data user not present present' do
        it "displays the vaccinations page without cr group and cr data user info" do
          sign_in create(:user)
          get vaccinations_user_path

          expect(response.body).not_to include(cr_access_path(cr_data_user))
          expect(response.body).not_to include(cr_group_path(cr_group))
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get vaccinations_user_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #share info" do
    context 'when signed in' do
      it "displays the share info page" do
        sign_in user
        get share_info_user_path

        expect(response.body).to include("Share Info")
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get share_info_user_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST #send info" do
    context 'when signed in' do
      context 'when user blank or invalid email' do
        it "redirects to share user info path and shows invalid email error" do
          sign_in user
          post send_info_user_path, params: { cr_access: { type: EMAIL, data: 'x@x.com' } }

          expect(response).to redirect_to share_info_user_path
          expect(flash[:alert]).to match(/Invalid Email*/)
        end
      end

      context 'when sharing data to yourself' do
        it "redirects to share user info path and shows can't share info to yourself error" do
          sign_in user
          post send_info_user_path, params: { cr_access: { type: EMAIL, data: user.email } }

          expect(response).to redirect_to share_info_user_path
          expect(flash[:alert]).to match(/Cannot share info to yourself.*/)
        end
      end

      context 'when invalid access' do
        it "redirects to share user info path and shows invalid access error" do
          sign_in user
          post send_info_user_path, params: { cr_access: { type: EMAIL, data: create(:user).email } }

          expect(response).to redirect_to share_info_user_path
          expect(flash[:alert]).to match(/Invalid Access.*/)
        end
      end

      context 'when valid access and data not already shared' do
        it "send the invite successfully" do
          sign_in user
          user.primary_cr_data = cr_access_data
          post send_info_user_path, params: { cr_access: { type: EMAIL, data: create(:user).email } }

          expect(response).to redirect_to vaccinations_user_path
        end
      end

      context 'when data already shared' do
        it "does not send the invite and shows the already shared data error" do
          sign_in user
          new_user = create(:user)
          new_user.all_cr_data << cr_access_data
          user.primary_cr_data = cr_access_data
          post send_info_user_path, params: { cr_access: { type: EMAIL, data: new_user.email } }

          expect(response).to redirect_to share_info_user_path
          expect(flash[:alert]).to match(/Data already shared with user.*/)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        post send_info_user_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #accept info" do
    context 'when signed in' do
      context 'when valid access' do
        it "linked info to profile and redirect to user vaccination path" do
          sign_in user
          get accept_info_user_path, params: { token: cr_data_user.invitation_token(user.id) }

          expect(flash[:notice]).to match(/Successfully linked info into your profile*/)
          expect(response).to redirect_to vaccinations_user_path
        end
      end

      context 'when invalid access' do
        it "redirects to root path" do
          sign_in user
          get accept_info_user_path, params: { token: cr_data_user.invitation_token(create(:user).id) }

          expect(flash[:alert]).to match(/Invalid Access*/)
          expect(response).to redirect_to root_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get accept_info_user_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #edit" do
    context 'when signed in' do
      it "display the edit page" do
        sign_in user
        user.primary_cr_data = cr_access_data
        get edit_user_path

        expect(response.body).to include("Welcome #{user.full_name}")
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get edit_user_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update" do
    context 'when signed in' do
      context 'valid user' do
        it "updates record and redirect to root path" do
          sign_in user
          params = { user: user.attributes.merge(first_name: 'test name', password: 'password', current_password: user.password, password_confirmation: 'password')}
          patch user_path, params: params

          expect(user.reload.first_name).to eql 'test name'
        end
      end

      context 'invalid user' do
        it "renders the edit page" do
          sign_in user
          params = { user: user.attributes.merge(first_name: '')}
          user.primary_cr_data = cr_access_data
          patch user_path, params: params

          expect(response).not_to be_redirect
          expect(response.body).to include("can&#39;t be blank")
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        patch user_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST #refresh vaccinations" do
    context 'when signed in' do
      it "refresh vaccinations" do
        sign_in user
        user.cr_access_data << cr_access_data
        post refresh_vaccinations_user_path

        expect(flash[:notice]).to match(/Successfully refreshed vaccinations*/)
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        post refresh_vaccinations_user_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
