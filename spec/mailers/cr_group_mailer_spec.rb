require "rails_helper"

RSpec.describe CrGroupMailer, type: :mailer do
  describe "#invite_cr_user" do
    it "renders the headers and text" do
      stub_request(:get, /passport|vault/)
      cr_access_group = create(:cr_access_group)
      cr_access_data = create(:cr_access_data)
      from = ENV.fetch('MAILER_SENDER_ADDRESS', 'no-reply@craccess.com')
      mail = CrGroupMailer.invite_cr_user(cr_access_data.id, cr_access_group.id)

      expect(mail.subject).to eq("Group Invitation")
      expect(mail.to).to eq([cr_access_data.email])
      expect(mail.from).to eq([from])
    end
  end
end
