# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DeviceAuthorizationsController do
  describe "POST /admin/device_authorizations" do
    subject(:action) { post admin_device_authorizations_path, as: :json, headers: }

    let(:headers) { { "User-Agent" => "RSpec Device Client" } }

    it "returns success" do
      action

      expect(response).to have_http_status(:success)
    end

    it "creates a pending device authorization" do
      expect { action }.to change(Admin::DeviceAuthorization, :count).by(1)
    end

    it "returns the RFC payload" do
      action

      user_code = response.parsed_body["user_code"]
      expect(response.parsed_body).to include(
        "device_code"               => a_kind_of(String),
        "user_code"                 => match(/\A[A-Z0-9]{4}-[A-Z0-9]{4}\z/),
        "verification_uri"          => a_string_ending_with("/admin/device_authorizations/#{user_code}"),
        "verification_uri_complete" => a_string_ending_with("/admin/device_authorizations/#{user_code}"),
        "expires_in"                => 600,
        "interval"                  => 5,
      )
    end

    it "persists only the digest of the device code" do
      action

      device_authorization = Admin::DeviceAuthorization.find_by!(user_code: response.parsed_body.fetch("user_code"))

      expect(device_authorization.device_code_digest).to eq(
        Admin::DeviceAuthorization.digest(response.parsed_body.fetch("device_code")),
      )
    end

    it "persists request metadata" do
      action

      device_authorization = Admin::DeviceAuthorization.order(:created_at).last

      expect(device_authorization).to have_attributes(
        requested_ip: "127.0.0.1",
        user_agent:   "RSpec Device Client",
      )
    end
  end
end
