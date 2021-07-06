require "rails_helper"

RSpec.describe "users#vaccinations", type: :system do
  around do |example|
    with_modified_env(VAULT_URL: "https://vault.com", &example)
  end

  it "qr code with cr access data as codeable" do
    stub_request(:get, /vault/)
    user = create(:user)
    cr_group = create(:cr_group)
    cr_data_user = create(:cr_data_user)
    login(user)
    user.cr_groups << cr_group
    user.cr_data_users << cr_data_user
    cr_data_user.accepted!
    visit vaccinations_user_path

    expect(page).to have_link('View', href: cr_access_path(cr_data_user))
    expect(page).to have_link('View', href: cr_group_path(cr_group))
  end
end
