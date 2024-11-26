# frozen_string_literal: true

require "rails_helper"
require "webauthn/fake_client"

RSpec.describe Admin::SessionsController do
  let(:admin) { create(:admin) }
  let(:client) { WebAuthn::FakeClient.new(origin) }
  let(:origin) { "http://www.example.com" }

  before do
    WebAuthn.configuration.origin = origin
  end

  describe "GET /admin/sessions/new" do
    let(:action) { get new_admin_session_path }

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/sessions" do
    let(:action) do
      get new_admin_session_path

      return nil unless response.successful?

      post admin_session_path,
           params: { admin: session_params },
           as:     :turbo_stream
    end

    context "with username/password" do
      let(:session_params) do
        {
          email:    admin.email,
          password: admin.password,
        }
      end

      it "renders successfully" do
        action
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "creates the admin session" do
        action
        expect(session[:admin_user_id]).to be_present
      end

      it "updates login metadata" do
        expect { action }.to(change { admin.reload.current_sign_in_at })
      end
    end

    context "with archived user" do
      let(:admin) { create(:admin, archived: true) }
      let(:session_params) do
        {
          email:    admin.email,
          password: admin.password,
        }
      end

      it "renders an error" do
        action
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create the admin session" do
        action
        expect(session[:admin_user_id]).not_to be_present
      end
    end

    context "with invalid credentials" do
      let(:session_params) do
        {
          email:    admin.email,
          password: "invalid",
        }
      end

      it "renders an error" do
        action
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create the admin session" do
        action
        expect(session[:admin_user_id]).not_to be_present
      end
    end

    context "with webauthn params" do
      before do
        relying_party = WebAuthn.configuration.relying_party
        result = client.create(challenge: Base64.urlsafe_encode64(SecureRandom.random_bytes(32)))

        response =
          WebAuthn::AuthenticatorAttestationResponse
            .new(
              attestation_object: Base64.urlsafe_decode64(result["response"]["attestationObject"]),
              client_data_json:   Base64.urlsafe_decode64(result["response"]["clientDataJSON"]),
              relying_party:,
            )

        admin.credentials.create!(
          external_id: Base64.urlsafe_encode64(response.credential.id, padding: false),
          nickname:    "My Key",
          public_key:  Base64.urlsafe_encode64(response.credential.public_key, padding: false),
          sign_count:  0,
        )
      end

      let(:session_params) do
        {
          response: client.get(challenge: session[:authentication_challenge]).to_json,
        }
      end

      it "renders successfully" do
        action
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "creates the admin session" do
        action
        expect(session[:admin_user_id]).to be_present
      end

      it "updates login metadata" do
        expect { action }.to(change { admin.reload.current_sign_in_at })
      end

      it "updates credential count" do
        expect { action }.to(change { admin.credentials.last.sign_count })
      end

      it "touches the credential" do
        expect { action }.to(change { admin.credentials.last.updated_at })
      end
    end
  end

  describe "DELETE /admin/session" do
    let(:action) do
      delete admin_session_path, as: :turbo_stream
    end

    include_context "with admin session"

    it "renders successfully" do
      action
      expect(response).to redirect_to(new_admin_session_path)
    end

    it "destroys the admin session" do
      action
      expect(session[:admin_user_id]).to be_nil
    end
  end
end
