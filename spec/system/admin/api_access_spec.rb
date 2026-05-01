# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/api access" do
  it "supports device flow approval and bearer-authenticated API access" do
    admin = create(:admin)
    device = Capybara::Session.new(:rack_test, Rails.application)

    device.driver.post(
      admin_device_authorizations_path,
      {},
      {
        "HTTP_ACCEPT"     => "application/json",
        "HTTP_USER_AGENT" => "RSpec Device Client",
      },
    )

    expect(device.status_code).to eq(200)

    device_response = JSON.parse(device.html)
    device_code = device_response.fetch("device_code")
    user_code = device_response.fetch("user_code")

    visit admin_device_authorization_path(user_code)

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"

    expect(page).to have_text("API access request")
    expect(page).to have_text(user_code)

    click_on "Approve"

    expect(page).to have_text("Approved")

    device.driver.post(
      admin_device_tokens_path,
      {
        grant_type:  "urn:ietf:params:oauth:grant-type:device_code",
        device_code:,
      },
      { "HTTP_ACCEPT" => "application/json" },
    )

    expect(device.status_code).to eq(200)

    token_response = JSON.parse(device.html)
    access_token = token_response.fetch("access_token")

    device.driver.get(
      "/admin/dashboard",
      {},
      {
        "HTTP_AUTHORIZATION" => "Bearer #{access_token}",
        "HTTP_ACCEPT"        => "text/html",
      },
    )

    expect(device.status_code).to eq(200)
  end
end
