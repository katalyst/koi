# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DeviceTokensController do
  describe "POST /admin/device_tokens" do
    subject(:action) { post admin_device_tokens_path, as: :json, params: }

    let(:params) do
      {
        grant_type:  "urn:ietf:params:oauth:grant-type:device_code",
        device_code:,
      }
    end
    let(:device_code) { "device-code-123" }

    it "returns authorization_pending for pending authorizations" do
      create(:admin_device_authorization, device_code_digest: Admin::DeviceAuthorization.digest(device_code))

      action

      expect(response.parsed_body).to eq("error" => "authorization_pending")
    end

    it "returns access_denied for denied authorizations" do
      create(:admin_device_authorization, :denied, device_code_digest: Admin::DeviceAuthorization.digest(device_code))

      action

      expect(response.parsed_body).to eq("error" => "access_denied")
    end

    it "returns invalid_grant for expired authorizations" do
      create(
        :admin_device_authorization,
        :approved,
        device_code_digest: Admin::DeviceAuthorization.digest(device_code),
        request_expires_at: 1.second.ago,
      )

      action

      expect(response.parsed_body).to eq("error" => "invalid_grant")
    end

    it "returns invalid_grant for consumed authorizations" do
      create(:admin_device_authorization, :consumed, device_code_digest: Admin::DeviceAuthorization.digest(device_code))

      action

      expect(response.parsed_body).to eq("error" => "invalid_grant")
    end

    it "returns invalid_grant for an unknown device code" do
      action

      expect(response.parsed_body).to eq("error" => "invalid_grant")
    end

    it "returns invalid_request for an invalid grant type" do
      post admin_device_tokens_path, as: :json, params: { grant_type: "invalid", device_code: }

      expect(response.parsed_body).to eq("error" => "invalid_request")
    end

    it "returns bad_request for error responses" do
      action

      expect(response).to have_http_status(:bad_request)
    end

    it "returns an access token for approved authorizations" do
      admin_user = create(:admin)
      create(
        :admin_device_authorization,
        :approved,
        admin_user:,
        device_code_digest: Admin::DeviceAuthorization.digest(device_code),
      )

      action

      expect(response.parsed_body).to include(
        "access_token" => a_kind_of(String),
        "token_type"   => "Bearer",
        "expires_in"   => 43_200,
      )
    end

    it "returns success for approved authorizations" do
      create(
        :admin_device_authorization,
        :approved,
        admin_user:         create(:admin),
        device_code_digest: Admin::DeviceAuthorization.digest(device_code),
      )

      action

      expect(response).to have_http_status(:success)
    end

    it "returns a token that authenticates the approving admin" do
      admin_user = create(:admin)
      create(
        :admin_device_authorization,
        :approved,
        admin_user:,
        device_code_digest: Admin::DeviceAuthorization.digest(device_code),
      )

      action

      expect(Admin::User.find_by_token_for(:api_access, response.parsed_body.fetch("access_token"))).to eq(admin_user)
    end

    it "consumes approved authorizations when issuing a token" do
      device_authorization = create(
        :admin_device_authorization,
        :approved,
        admin_user:         create(:admin),
        device_code_digest: Admin::DeviceAuthorization.digest(device_code),
      )

      action

      expect(device_authorization.reload).to have_attributes(
        status:           "consumed",
        consumed_at:      be_present,
        token_expires_at: be_present,
      )
    end
  end
end
