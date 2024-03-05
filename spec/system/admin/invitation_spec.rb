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

  it "can accept an invitation" do
    admin = create(:admin, password: "")
    token = encode_token(admin_id: admin.id, exp: 1.hour.from_now.to_i, ist: Time.now.to_i)

    visit "admin/token/#{token}"

    expect(page).to have_content(/Welcome to Koi Admin/)

    click_button "Sign in"

    expect(page).to have_current_path(admin_admin_user_path(admin))
  end
end
