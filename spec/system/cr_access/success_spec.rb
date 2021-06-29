require 'rails_helper'

RSpec.describe "cr_access#success", type: :system do
  it "success page when new record" do
    stub_request(:get, /passport|vault/)
    user = create(:user)
    cr_access_data = create(:cr_access_data, :profile_picture)
    user.cr_access_data << cr_access_data
    visit success_cr_access_path(user, new_record: true)

    expect(page).to have_text "An email has been sent to you."
  end

  it "success page when old record" do
    stub_request(:get, /passport|vault/)
    user = create(:user)
    cr_access_data = create(:cr_access_data, :profile_picture)
    user.cr_access_data << cr_access_data
    visit success_cr_access_path(user)

    expect(page).to have_text "You already have an account with the email #{user.email}, use that to login."
  end
end
