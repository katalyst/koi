# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/invites" do
  def encode_token(**args)
    JWT.encode(args, Rails.application.secret_key_base)
  end

  it "creates an invitation" do
    admin = create(:admin)
    visit "/admin"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_on "Log in"

    visit "/admin/admin_users/new"

    fill_in "Email", with: "john.doe@gmail.com"
    fill_in "Name", with: "John Doe"

    click_button "Save"

    expect(page).to have_css("button", text: "Invite")

    click_button "Invite"

    expect(page).to have_css("input[type=text][value*=token]")
  end

  it "can accept an invitation and signup with password" do
    admin = create(:admin, password: "")
    token = encode_token(admin_id: admin.id, exp: 1.hour.from_now.to_i, ist: Time.now.to_i)

    visit "admin/session/new?token=#{token}"

    expect(page).to have_content(/Sign up to admin terminal/)

    click_button "Signup with password"

    expect(page).to have_css("input[type=password]")

    fill_in "Password", with: "password"

    click_button "Save"

    expect(page).to have_content(admin.email)

    click_link "Dashboard"

    expect(page).to have_current_path("/admin/dashboard")
  end

  it "can accept an invitation and signup with passkey" do
    admin = create(:admin, password: "")
    token = encode_token(admin_id: admin.id, exp: 1.hour.from_now.to_i, ist: Time.now.to_i)

    visit "admin/session/new?token=#{token}"

    expect(page).to have_content(/Sign up to admin terminal/)

    click_button "Signup with passkey"

    expect(page).to have_current_path(new_admin_admin_user_credential_path(admin))
    within("#kpop") do |kpop|
      expect(kpop).to have_content("Register device")
    end
  end
end
