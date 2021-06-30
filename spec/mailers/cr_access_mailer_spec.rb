require "rails_helper"

RSpec.describe CrAccessMailer, type: :mailer do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  describe "#share_data" do
    it "renders the headers and text" do
      stub_request(:get, /vault/)
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
