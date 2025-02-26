# frozen_string_literal: true

require "rails_helper"
require "webauthn/fake_client"

RSpec.describe Admin::SessionsController do
  let(:admin) { create(:admin) }
  let(:client) { WebAuthn::FakeClient.new(origin) }
  let(:origin) { "http://www.example.com" }

  before do
    WebAuthn.configuration.allowed_origins = [origin]
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

    it "accepts email and prompts for password" do
      post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content).and(have_rendered("password"))
    end

    it "accepts invalid emails without leaking account existence" do
      post admin_session_path, params: { admin: { email: "invalid@example.com" } }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content).and(have_rendered("password"))
    end

    it "fails on invalid email" do
      post admin_session_path, params: { admin: { email: "invalid@example.com" } }, as: :turbo_stream
      post admin_session_path, params: { admin: { email: "invalid@example.com", password: admin.password } },
                               as:     :turbo_stream
      expect(response).to have_http_status(:unprocessable_content).and(have_rendered("new"))
    end

    it "fails on invalid password" do
      post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
      post admin_session_path, params: { admin: { email: admin.email, password: "invalid" } }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content).and(have_rendered("new"))
    end

    it "accepts email and password and prompts for otp" do
      post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
      post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content).and(have_rendered("otp"))
    end

    it "fails on invalid otp" do
      post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
      post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }, as: :turbo_stream
      post admin_session_path, params: { admin: { token: "000000" } }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content).and(have_rendered("new"))
    end

    it "accepts otp and redirects to dashboard" do
      post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
      post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }, as: :turbo_stream
      post admin_session_path, params: { admin: { token: admin.otp.now } }, as: :turbo_stream
      expect(response).to have_http_status(:see_other).and(redirect_to(admin_dashboard_path))
    end

    it "accepts otp and updates login metadata" do
      expect do
        post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
        post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }, as: :turbo_stream
        post admin_session_path, params: { admin: { token: admin.otp.now } }, as: :turbo_stream
      end.to(change { admin.reload.current_sign_in_at })
    end

    context "with no otp present" do
      let(:admin) { create(:admin, otp_secret: "") }

      it "accepts otp and redirects to dashboard" do
        post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
        post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }, as: :turbo_stream
        expect(response).to have_http_status(:see_other).and(redirect_to(admin_dashboard_path))
      end
    end

    context "with archived user" do
      let(:admin) { create(:admin, archived: true) }

      it "fails after email and password" do
        post admin_session_path, params: { admin: { email: admin.email } }, as: :turbo_stream
        post admin_session_path, params: { admin: { email: admin.email, password: admin.password } }, as: :turbo_stream
        expect(response).to have_http_status(:unprocessable_content).and(have_rendered("new"))
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
