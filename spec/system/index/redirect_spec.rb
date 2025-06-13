# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/redirect" do
  let(:admin) { create(:admin) }
  let!(:announcement) { create(:announcement) }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"
  end

  it "can redirect to index via turbo" do
    visit edit_admin_announcement_path(announcement)

    click_on "Archive"

    accept_confirm do
      click_on "Delete"
    end

    expect(page).to have_current_path(admin_announcements_path)
    expect(page).to have_css("a[href]", text: "New")
  end
end
