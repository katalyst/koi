# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/table" do
  let(:admin) { create(:admin) }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"
  end

  it "renders a table" do
    announcements = create_list(:announcement, 3)

    visit "/admin/announcements"

    expect(page).to have_css("td", text: announcements.first.title)
  end

  context "when there are no results" do
    it "shows a placeholder message" do
      visit "/admin/announcements"

      expect(page).to have_css("caption", text: "No announcements found.")
    end
  end
end
