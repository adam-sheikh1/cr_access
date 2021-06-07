require "rails_helper"

RSpec.describe CrAccessMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:cr_data_user) { create(:cr_data_user, :with_cr_access_data, user: user) }
  let(:from) { ENV.fetch('MAILER_SENDER_ADDRESS', 'no-reply@craccess.com') }
  let(:mail) { CrAccessMailer.share_data(user.id, cr_data_user.id) }

  describe "#share_data" do
    it "renders the headers and text" do
      expect(mail.subject).to eq("Data Sharing Invitation")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([from])
    end
  end
end
