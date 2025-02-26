# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/invites" do
  it "creates an invitation" do
    admin = create(:admin)
    visit "/admin/admin_users/new"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"

    fill_in "Email", with: "john.doe@gmail.com"
    fill_in "Name", with: "John Doe"

    click_on "Save"

    click_on "Generate login link"

    expect(page).to have_css("input[type=text][value*=token]")
  end

  it "can accept an invitation" do
    admin = create(:admin, password: "")
    token = admin.generate_token_for(:password_reset)

    visit "admin/session/tokens/#{token}"

    expect(page).to have_content(/Welcome to Koi Admin/)

    click_on "Sign in"

    expect(page).to have_current_path(admin_admin_user_path(admin))
  end
end
