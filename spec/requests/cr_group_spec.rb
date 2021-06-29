require 'rails_helper'

RSpec.describe "CrGroup", type: :request do
  describe "GET #show" do
    context 'when signed in' do
      context 'when cr group accessible' do
        it "displays the show page" do
          user = create(:user)
          cr_group = create(:cr_group, user: user)
          sign_in user
          get cr_group_path(cr_group)

          expect(response.body).to include("Group #{cr_group.name} Details:")
          expect(response.body).to_not include(shared_record_path(cr_group))
          expect(response).to be_successful
        end
      end

      context 'when cr group not accessible' do
        it "redirects to user vaccination page" do
          user = create(:user)
          sign_in user
          new_cr_group = create(:cr_group, user: create(:user))
          get cr_group_path(new_cr_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        cr_group = create(:cr_group, user: user)
        get cr_group_path(cr_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #invite" do
    context 'when signed in' do
      context 'when cr group accessible' do
        it "displays the invite page" do
          user = create(:user)
          cr_group = create(:cr_group, user: user)
          sign_in user
          get invite_cr_group_path(cr_group)

          expect(response.body).to include("Add to Group")
        end
      end

      context 'when cr group not accessible' do
        it "redirects to user vaccination page" do
          user = create(:user)
          cr_group = create(:cr_group, user: user)
          new_user = create(:user)
          sign_in new_user
          get invite_cr_group_path(cr_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        cr_group = create(:cr_group, user: user)
        get invite_cr_group_path(cr_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST #send_invite" do
    context 'when signed in' do
      context 'when cr group accessible' do
        context 'when valid type' do
          it "send the invite successfully" do
            stub_request(:get, /passport|vault/)
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            cr_access_data = create(:cr_access_data)
            sign_in user
            cr_group.cr_access_data << cr_access_data
            new_cr_access_data = create(:cr_access_data)
            mailer = double("mailer", deliver_later: nil)

            expect(CrGroupMailer).to receive(:invite_cr_user).with(any_args).and_return(mailer)
            expect(mailer).to receive(:deliver_later)

            post send_invite_cr_group_path(cr_group), params: { invite: { type: EMAIL, data: new_cr_access_data.email } }
          end
        end

        context 'when invalid type' do
          it "redirects to invite page and shows the invalid type error" do
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            sign_in user

            expect(CrGroupMailer).not_to receive(:invite_cr_user)

            post send_invite_cr_group_path(cr_group), params: { invite: { type: '', data: user.email } }

            expect(flash[:alert]).to match(/Invalid Type*/)
            expect(response).to redirect_to invite_cr_group_path(cr_group)
          end
        end
      end

      context 'when cr group not accessible' do
        it "redirects to user vaccination page" do
          user = create(:user)
          cr_group = create(:cr_group, user: user)
          new_user = create(:user)
          sign_in new_user
          post send_invite_cr_group_path(cr_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        cr_group = create(:cr_group, user: user)
        post send_invite_cr_group_path(cr_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #new" do
    context 'when signed in' do
      it "display the new page" do
        user = create(:user)
        sign_in user
        get new_cr_group_path

        expect(response.body).to include("Create Group")
        expect(response).to be_successful
      end

      it "fetches the correct groups" do
        user = create(:user)
        sign_in user
        create_list(:cr_group, 2, user: user)
        get new_cr_group_path

        user.cr_groups.each do |group|
          expect(response.body).to include(cr_group_path(group))
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        get new_cr_group_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST #create" do
    context 'when signed in' do
      context 'valid cr group' do
        it "inserts row in table" do
          user = create(:user)
          sign_in user
          new_cr_group = build(:cr_group)
          params = { cr_group: new_cr_group.attributes.except("id")}

          expect { post cr_groups_path, params: params }.to change(CrGroup, :count).by(1)
        end
      end

      context 'invalid cr group' do
        it "does not insert new row" do
          user = create(:user)
          sign_in user

          expect{ post cr_groups_path, params: { cr_group: { name: '' } } }.to_not change(CrGroup, :count)
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        post cr_groups_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #edit" do
    context 'when signed in' do
      context 'when cr group accessible' do
        it "display the edit page" do
          user = create(:user)
          cr_group = create(:cr_group, user: user)
          sign_in user
          get edit_cr_group_path(cr_group)

          expect(response.body).to include("Edit Group")
          expect(response).to be_successful
        end
      end

      context 'when cr group not accessible' do
        it "redirects to user vaccination page" do
          user = create(:user)
          sign_in user
          new_cr_group = create(:cr_group, user: create(:user))
          get edit_cr_group_path(new_cr_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        cr_group = create(:cr_group, user: user)
        get edit_cr_group_path(cr_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #update" do
    context 'when signed in' do
      context 'when cr group accessible' do
        context 'valid cr group' do
          it "updates record and redirect to show page" do
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            sign_in user
            params = { cr_group: cr_group.attributes.merge(name: 'test name')}
            patch cr_group_path(cr_group), params: params

            expect(cr_group.reload.name).to eql 'test name'
            expect(response).to redirect_to cr_group_path(cr_group)
          end
        end

        context 'invalid cr group' do
          it "renders the edit page" do
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            sign_in user
            params = { cr_group: cr_group.attributes.merge(name: '')}

            expect { patch cr_group_path(cr_group), params: params }.to_not change { cr_group.reload.attributes }
          end
        end
      end

      context 'when cr group not accessible' do
        it "redirects to user vaccination page" do
          user = create(:user)
          sign_in user
          new_cr_group = create(:cr_group, user: create(:user))

          expect { patch cr_group_path(new_cr_group) }.to_not change { new_cr_group.reload.attributes }
          expect(response).to redirect_to vaccinations_user_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        cr_group = create(:cr_group, user: user)
        patch cr_group_path(cr_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #leave" do
    context 'when signed in' do
      context 'when cr group accessible' do
        context 'when no cr access group found' do
          it "can't leave the group" do
            stub_request(:get, /passport|vault/)
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            sign_in user
            cr_access_group = create(:cr_access_group)
            user.primary_cr_data = cr_access_group.cr_access_data

            expect{ delete leave_cr_group_path(cr_group) }.to_not change(CrAccessGroup, :count)
          end
        end

        context 'when cr access group found' do
          it "leaves the group" do
            stub_request(:get, /passport|vault/)
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            sign_in user
            cr_access_group = create(:cr_access_group)
            cr_group.cr_access_groups << cr_access_group
            user.primary_cr_data = cr_access_group.cr_access_data
            delete leave_cr_group_path(cr_group)

            expect(CrAccessGroup.find_by(id: cr_access_group.id)).to be_nil
          end
        end
      end

      context 'when cr group not accessible' do
        it "redirects to user vaccination page" do
          user = create(:user)
          sign_in user
          new_cr_group = create(:cr_group, user: create(:user))

          expect{ delete leave_cr_group_path(new_cr_group) }.to_not change(CrAccessGroup, :count)
          expect(response).to redirect_to vaccinations_user_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        cr_group = create(:cr_group, user: user)

        expect{ delete leave_cr_group_path(cr_group) }.to_not change(CrAccessGroup, :count)
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #remove" do
    context 'when signed in' do
      context 'when cr group accessible' do
        context 'when no cr access group found' do
          it "can't remove from the group" do
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            sign_in user

            expect{ delete remove_cr_group_path(cr_group) }.to_not change(CrAccessGroup, :count)
          end
        end

        context 'when cr access group found' do
          it "remove from the group" do
            stub_request(:get, /passport|vault/)
            user = create(:user)
            cr_group = create(:cr_group, user: user)
            sign_in user
            cr_access_group = create(:cr_access_group)
            cr_group.cr_access_groups << cr_access_group
            delete remove_cr_group_path(cr_group), params: { data_id: cr_access_group.cr_access_data_id }

            expect(CrAccessGroup.find_by(id: cr_access_group.id)).to be_nil
          end
        end
      end

      context 'when cr group not accessible' do
        it "redirects to user vaccination page" do
          user = create(:user)
          sign_in user
          new_cr_group = create(:cr_group, user: create(:user))
          delete remove_cr_group_path(new_cr_group)

          expect(response).to redirect_to vaccinations_user_path
        end
      end
    end

    context 'when not signed in' do
      it "redirects to login page" do
        user = create(:user)
        cr_group = create(:cr_group, user: user)
        delete remove_cr_group_path(cr_group)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
