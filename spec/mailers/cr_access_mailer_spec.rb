require "rails_helper"

RSpec.describe CrAccessMailer, type: :mailer do
  describe "#share_data" do
    it "renders the headers and text" do
      stub_request(:get, /passport|vault/)
      user = create(:user)
      cr_data_user = create(:cr_data_user, user: user)
      from = ENV.fetch('MAILER_SENDER_ADDRESS', 'no-reply@craccess.com')
      mail = CrAccessMailer.share_data(user.id, cr_data_user.id)

      expect(mail.subject).to eq("Data Sharing Invitation")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([from])
    end
  end
end
