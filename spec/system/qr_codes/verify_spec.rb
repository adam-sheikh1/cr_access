require "rails_helper"

RSpec.describe "qr_codes#verify", type: :system do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  it "qr code with cr access data as codeable" do
    stub_request(:get, /vault/)
    qr_code_with_cr_access_data = create(:qr_code, :with_cr_access_data)
    visit verify_qr_codes_path(code: qr_code_with_cr_access_data.code)

    expect(page).to have_text 'Welcome'
    expect(page).to have_text qr_code_with_cr_access_data.codeable.fv_code.code
  end

  it "qr code with cr access group as codeable" do
    stub_request(:get, /vault/)
    qr_code_with_cr_group =  create(:qr_code, :with_cr_group)
    visit verify_qr_codes_path(code: qr_code_with_cr_group.code)

    expect(page).to have_text 'Welcome'
    expect(page).to_not have_text qr_code_with_cr_group.codeable.fv_code.code
  end
end
