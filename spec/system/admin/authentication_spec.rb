# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/authentication" do
  it "supports password login" do
    admin = create(:admin)
    visit "/admin"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_on "Log in"

    expect(page).to have_current_path("/admin/dashboard")
  end

  it "supports redirect after login" do
    admin = create(:admin)
    visit "/admin/admin_users"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_on "Log in"

    expect(page).to have_current_path("/admin/admin_users")
  end
end
