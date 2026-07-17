# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::TokensController do
  describe "POST /admin/tokens with a device code" do
    let(:device_code) { "device-code-123" }

    def action(as: :json,
               grant_type: "urn:ietf:params:oauth:grant-type:device-code",
               device_code: self.device_code,
               **params)
      post(admin_tokens_path, as:, params: { grant_type:, device_code:, **params })
    end

    def device_code_digest
      Admin::DeviceAuthorization.digest(device_code)
    end

    it "returns authorization_pending for pending authorizations" do
      create(:admin_device_authorization, device_code_digest:)

      action

      expect(response.parsed_body).to eq("error" => "authorization_pending")
    end

    it "returns access_denied for denied authorizations" do
      create(:admin_device_authorization, :denied, device_code_digest:)

      action

      expect(response.parsed_body).to eq("error" => "access_denied")
    end

    it "returns invalid_grant for expired authorizations" do
      create(
        :admin_device_authorization,
        :approved,
        device_code_digest:,
        request_expires_at: 1.second.ago,
      )

      action

      expect(response.parsed_body).to eq("error" => "invalid_grant")
    end

    it "returns invalid_grant for consumed authorizations" do
      create(:admin_device_authorization, :consumed, device_code_digest:)

      action

      expect(response.parsed_body).to eq("error" => "invalid_grant")
    end

    it "returns invalid_grant for an unknown device code" do
      action

      expect(response.parsed_body).to eq("error" => "invalid_grant")
    end

    it "returns invalid_request for an invalid grant type" do
      action(grant_type: "invalid")

      expect(response.parsed_body).to eq("error" => "invalid_request")
    end

    it "returns bad_request for error responses" do
      action

      expect(response).to have_http_status(:bad_request)
    end

    it "returns an access token for approved authorizations" do
      create(:admin_device_authorization, :approved, device_code_digest:)

      action

      expect(response.parsed_body).to include(
        "access_token" => a_kind_of(String),
        "token_type"   => "Bearer",
        "expires_in"   => 3600,
      )
    end

    it "returns success for approved authorizations" do
      create(:admin_device_authorization, :approved, device_code_digest:)

      action

      expect(response).to have_http_status(:success)
    end

    it "returns a token that authenticates the approving admin" do
      device_authorization = create(:admin_device_authorization, :approved, device_code_digest:)

      action

      access_token = response.parsed_body.fetch("access_token")
      expect(Admin::DeviceAuthorization.find_by_token_for(:api_access, access_token))
        .to eq(device_authorization)
    end

    it "consumes approved authorizations when issuing a token" do
      device_authorization = create(:admin_device_authorization, :approved, device_code_digest:)

      action

      expect(device_authorization.reload).to have_attributes(
        status:           "consumed",
        consumed_at:      be_present,
        token_expires_at: be_present,
      )
    end
  end
end
