# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/authentication" do
  it "supports password login with 2fa" do
    admin = create(:admin)
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"

    expect(page).to have_current_path("/admin/dashboard")
  end

  it "supports password login without 2fa" do
    admin = create(:admin, otp_secret: "")
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    expect(page).to have_current_path("/admin/dashboard")
  end

  it "supports redirect after login" do
    admin = create(:admin)
    visit "/admin/admin_users"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"

    expect(page).to have_current_path("/admin/admin_users")
  end
end
