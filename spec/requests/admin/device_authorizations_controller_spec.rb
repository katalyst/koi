# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DeviceAuthorizationsController do
  let(:admin) { create(:admin_user) }

  describe "GET /admin/device_authorizations/:user_code" do
    let(:action) { get admin_device_authorization_path(device_authorization.user_code) }

    let(:device_authorization) { create(:admin_device_authorization) }

    include_context "with admin session"

    it_behaves_like "requires admin"

    it "renders successfully" do
      action

      expect(response).to have_http_status(:success)
    end

    it "shows the approval UI" do
      action

      expect(response.parsed_body).to have_css(:button, text: "Approve")
    end

    context "with an expired authorization" do
      let(:device_authorization) do
        create(:admin_device_authorization, request_expires_at: 1.second.ago)
      end

      it "shows expired token" do
        action

        expect(response.parsed_body).to have_css(:td, text: /Less than a minute ago/)
      end
    end

    context "with an unknown authorization" do
      let(:device_authorization) { build(:admin_device_authorization, user_code: "UNKNOWN") }

      it "returns not found" do
        action

        expect(response).to have_http_status(:not_found)
      end
    end
  end

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

  describe "PATCH /admin/device_authorizations/:user_code" do
    subject(:action) do
      patch admin_device_authorization_path(device_authorization.user_code), params: { decision: "approve" }
    end

    let(:device_authorization) { create(:admin_device_authorization) }

    include_context "with admin session"

    it_behaves_like "requires admin"

    it "approves the authorization" do
      action

      expect(device_authorization.reload).to have_attributes(
        status:      "approved",
        admin_user:  admin,
        approved_at: be_present,
      )
    end

    it "redirects back to the authorization page" do
      action

      expect(response).to redirect_to(admin_device_authorization_path(device_authorization.user_code))
    end

    context "when denying" do
      subject(:action) do
        patch admin_device_authorization_path(device_authorization.user_code), params: { decision: "deny" }
      end

      it "updates the authorization" do
        action

        expect(device_authorization.reload).to have_attributes(
          status:     "denied",
          admin_user: admin,
        )
      end
    end

    context "when the authorization is expired" do
      let(:device_authorization) { create(:admin_device_authorization, request_expires_at: 1.second.ago) }
      let(:decision) { "approve" }

      it "does not change the authorization" do
        expect { action }.not_to(change { device_authorization.reload.status })
      end

      it "renders the show page as unprocessable" do
        action

        expect(response.parsed_body).to have_css(:td, text: /Less than a minute ago/)
      end
    end

    context "when the authorization is already terminal" do
      let(:device_authorization) { create(:admin_device_authorization, :denied) }
      let(:decision) { "approve" }

      it "does not change the authorization" do
        expect { action }.not_to(change { device_authorization.reload.status })
      end

      it "renders the show page as unprocessable" do
        action

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
