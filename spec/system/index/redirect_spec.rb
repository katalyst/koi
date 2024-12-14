# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/pagination" do
  let(:admin) { create(:admin) }
  let!(:post) { create(:post) }

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
    visit edit_admin_post_path(post)

    expect(page).to have_css(".button", text: "Delete")

    accept_confirm do
      click_on "Delete"
    end

    expect(page).to have_current_path(admin_posts_path)
    expect(page).to have_css("a[href]", text: "New")
  end
end
