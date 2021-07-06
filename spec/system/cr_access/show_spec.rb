require "rails_helper"

RSpec.describe "cr_access#show", type: :system do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  it "show page" do
    stub_request(:get, /vault/)
    user = create(:user)
    cr_data_user = create(:cr_data_user)
    login(user)
    cr_data_user.update(data_type: CrDataUser::DATA_TYPES[:prepmod], status: CrDataUser::STATUSES[:accepted])
    user.cr_data_users << cr_data_user
    visit cr_access_path(cr_data_user)

    expect(page).to have_text "Info"
    expect(page).to have_text cr_data_user.cr_access_data.fv_code.code
  end
end
