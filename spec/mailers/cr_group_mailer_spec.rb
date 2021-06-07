require "rails_helper"

RSpec.describe CrGroupMailer, type: :mailer do
  let(:cr_access_group) { create(:cr_access_group, :with_cr_access_data, :with_cr_group) }
  let(:cr_access_data) { create(:cr_access_data) }
  let(:from) { ENV.fetch('MAILER_SENDER_ADDRESS', 'no-reply@craccess.com') }
  let(:mail) { CrGroupMailer.invite_cr_user(cr_access_data.id, cr_access_group.id)}

  describe "#invite_cr_user" do
    it "renders the headers and text" do
      expect(mail.subject).to eq("Group Invitation")
      expect(mail.to).to eq([cr_access_data.email])
      expect(mail.from).to eq([from])
    end
  end
end
