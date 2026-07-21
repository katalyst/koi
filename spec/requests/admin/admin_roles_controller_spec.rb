# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::AdminRolesController do
  let(:role) { create(:admin_role) }

  include_context "with admin session"

  describe "GET /admin/admin_roles" do
    let(:action) { get admin_admin_roles_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      role
      action

      expect(response).to have_http_status(:success)
    end

    it_behaves_like "with bearer token authentication" do
      it "fails with an authentication error" do
        get(admin_admin_roles_path, headers:)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /admin/admin_roles/:id" do
    let(:action) { get admin_admin_role_path(role) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action

      expect(response).to have_http_status(:success)
    end

    context "with members granting the role" do
      let(:role) { create(:admin_role, slug: "event_editor") }
      let(:issuer) { "https://00000000-0000-0000-0000-000000000000.tokens.sts.global.api.aws" }
      let(:task_role_arn) { "arn:aws:iam::123456789012:role/avr-legacy-task" }

      let(:komet_jwk) { JWT::JWK.new(OpenSSL::PKey::EC.generate("secp384r1")) }
      let(:aws_jwk) { JWT::JWK.new(OpenSSL::PKey::EC.generate("secp384r1")) }

      def thumbprint(jwk)
        JWT::JWK::Thumbprint.new(jwk).generate
      end

      before do
        ENV["KOI_API_JWKS_KOMET"] = { keys: [komet_jwk.export] }.to_json
        Koi.config.identity       = {
          providers: {
            aws:   { issuer:, keys: "discover" },
            komet: { issuer: "komet", keys: "env" },
          },
          members:   {
            avr_legacy: { provider: :aws, scope: "admin/role/event_editor", subject: task_role_arn },
            komet:      { provider: :komet, scope: "admin/role/event_editor", subject: "komet-production" },
          },
        }

        stub_request(:get, "#{issuer}/.well-known/openid-configuration")
          .to_return(headers: { "Content-Type" => "application/json" },
                     body:    { issuer:, jwks_uri: "#{issuer}/keys" }.to_json)
        stub_request(:get, "#{issuer}/keys")
          .to_return(headers: { "Content-Type" => "application/json" },
                     body:    { keys: [aws_jwk.export] }.to_json)
      end

      after do
        ENV.delete("KOI_API_JWKS_KOMET")
        Koi.config.instance_variable_set(:@identity, nil)
      end

      it "renders the role's trust detail", :aggregate_failures do
        action

        expect(response.body).to include("komet-production").and include(task_role_arn)
        expect(response.body).to include(issuer)
      end

      it "renders pinned key fingerprints" do
        action

        expect(response.body).to include(thumbprint(komet_jwk))
      end

      it "renders discovered key cache state" do
        action

        expect(response.body).to include(thumbprint(aws_jwk)).and include("fetched")
      end

      it "reports an unreachable issuer without failing", :aggregate_failures do
        stub_request(:get, "#{issuer}/.well-known/openid-configuration").to_timeout

        action

        expect(response).to have_http_status(:success)
        expect(response.body).to include("key discovery for aws failed")
      end
    end
  end
end
