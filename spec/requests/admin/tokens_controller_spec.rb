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

  describe "POST /admin/tokens with a signed jwt" do
    let(:issuer) { "https://00000000-0000-0000-0000-000000000000.tokens.sts.global.api.aws" }
    let(:admin) { create(:admin) }

    def action(as: :json,
               grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
               assertion: self.assertion,
               **params)
      post(admin_tokens_path, as:, params: { grant_type:, assertion:, **params })
    end

    before do
      Koi.config.identity = {
        providers: {
          katalyst_agents: {
            issuer:,
            keys:    "discover",
            subject: "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com" \
                     "/ap-southeast-2/AWSReservedSSO_Engineer_0123456789abcdef",
            scope:   "admin_user",
          },
        },
      }
    end

    after { Koi.config.instance_variable_set(:@identity, nil) }

    context "with a simulated AWS issuer" do
      let(:audience) { "http://www.example.com/admin" }
      let(:signing_key) { OpenSSL::PKey::EC.generate("secp384r1") }
      let(:jwk) { JWT::JWK.new(signing_key) }

      def claims(iss: issuer,
                 sub: "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com" \
                      "/ap-southeast-2/AWSReservedSSO_Engineer_0123456789abcdef",
                 aud: audience,
                 iat: Time.zone.now.to_i,
                 exp: iat + 300,
                 jti: SecureRandom.uuid,
                 admin: self.admin)
        {
          iss:,
          sub:,
          aud:,
          iat:,
          exp:,
          jti:,
          "https://sts.amazonaws.com/" => {
            "principal_tags" => { "email" => admin.email, "name" => admin.name },
          },
        }
      end

      def assertion(signing_key: self.signing_key, kid: jwk.kid, **)
        JWT.encode(claims(**), signing_key, "ES384", { kid: })
      end

      before do
        stub_request(:get, "#{issuer}/.well-known/openid-configuration")
          .to_return(headers: { "Content-Type" => "application/json" },
                     body:    { issuer:, jwks_uri: "#{issuer}/keys" }.to_json)
        stub_request(:get, "#{issuer}/keys")
          .to_return(headers: { "Content-Type" => "application/json" },
                     body:    { keys: [jwk.export] }.to_json)
      end

      it "exchanges the assertion for a bearer token", :aggregate_failures do
        action

        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to include(
          "access_token" => a_kind_of(String),
          "token_type"   => "Bearer",
          "expires_in"   => 3600,
        )
      end

      it "does not touch the Rails session", :aggregate_failures do
        expect { action }.not_to change(Admin::Session, :count)
        expect(response.headers["Set-Cookie"]).to be_blank
      end

      def token
        action
        response.parsed_body.fetch("access_token")
      end

      it "issues a token that authenticates admin API requests without a session", :aggregate_failures do
        get "/admin/dashboard", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:success)
        expect(response.headers["Set-Cookie"]).to be_blank
      end

      it "invalidates issued tokens alongside the admin's others when they sign in again" do
        bearer = token
        admin.update!(last_sign_in_at: 1.second.from_now)

        get "/admin/dashboard", headers: { "Authorization" => "Bearer #{bearer}" }

        expect(response).to have_http_status(:unauthorized)
      end

      it "rejects invalid assertions without detail", :aggregate_failures do
        action(assertion: assertion(signing_key: OpenSSL::PKey::EC.generate("secp384r1")))

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq("error" => "invalid_grant")
      end

      it "rate limits token exchanges" do
        allow(described_class.cache_store).to receive(:increment).and_return(21)

        action

        expect(response).to have_http_status(:too_many_requests)
      end

      it "logs rejections with issuer and subject", :aggregate_failures do
        allow(Rails.logger).to receive(:warn)

        action(assertion: assertion(sub: "arn:aws:iam::123456789012:role/unrelated-task-role"))

        expect(response).to have_http_status(:bad_request)
        expect(Rails.logger).to have_received(:warn)
                                  .with(a_string_including(issuer).and(a_string_including("unrelated-task-role")))
      end

      it "matches admins through email normalization" do
        loud = Struct.new(:email, :name).new(" #{admin.email.upcase} ", admin.name)

        action(assertion: assertion(admin: loud))

        expect(response).to have_http_status(:success)
      end

      it "rejects an assertion minted for another site without detail", :aggregate_failures do
        action(assertion: assertion(aud: "https://elsewhere.example.com/admin"))

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq("error" => "invalid_grant")
      end

      it "prefers the provider's pinned audience over the requesting site" do
        Koi.config.identity = { providers: { katalyst_agents: { audience: "https://pinned.example.com/admin" } } }

        action(assertion: assertion(aud: "https://pinned.example.com/admin"))

        expect(response).to have_http_status(:success)
      end

      it "rejects an assertion for an archived admin without detail", :aggregate_failures do
        admin.archive!

        action

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq("error" => "invalid_grant")
      end

      it "rejects an assertion from a provider with no identity mapping without detail", :aggregate_failures do
        Koi.config.identity = {
          providers: {
            partner: {
              issuer:   "https://partner.example.com",
              keys:     "discover",
              audience:,
              subject:  claims[:sub],
              scope:    "admin_user",
            },
          },
        }
        stub_request(:get, "https://partner.example.com/.well-known/openid-configuration")
          .to_return(headers: { "Content-Type" => "application/json" },
                     body:    { issuer:   "https://partner.example.com",
                                jwks_uri: "https://partner.example.com/keys" }.to_json)
        stub_request(:get, "https://partner.example.com/keys")
          .to_return(headers: { "Content-Type" => "application/json" },
                     body:    { keys: [jwk.export] }.to_json)

        action(assertion: assertion(iss: "https://partner.example.com"))

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq("error" => "invalid_grant")
      end

      it "rejects an assertion whose identity claim matches no admin without detail", :aggregate_failures do
        action(assertion: assertion(admin: build(:admin, email: "nobody@katalyst.com.au")))

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq("error" => "invalid_grant")
      end
    end
  end
end
