# frozen_string_literal: true

require "rails_helper"
require "webauthn/fake_client"

RSpec.describe Admin::CredentialsController do
  let(:admin) { create(:admin) }
  let(:client) { WebAuthn::FakeClient.new(origin) }
  let(:origin) { "http://www.example.com" }

  before do
    WebAuthn.configuration.origin = origin
  end

  include_context "with admin session"

  describe "GET /admin/admin_users/:admin_user_id/credential/new" do
    let(:action) { get new_admin_admin_user_credential_path(admin), as: :turbo_stream }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/admin_users/:admin_user_id/credential" do
    let(:action) do
      get new_admin_admin_user_credential_path(admin)

      return unless response.successful?

      post admin_admin_user_credentials_path(admin),
           params: { admin_credential: credential_params },
           as:     :turbo_stream
    end

    let(:credential_params) do
      {
        nickname: "My Key",
        response: client.create(challenge: session[:creation_challenge]).to_json,
      }
    end

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_admin_user_path(admin))
    end

    it "creates an admin credential" do
      expect { action }.to(change { admin.credentials.reload.count }.by(1))
    end
  end

  describe "DELETE /admin/admin_users/:id" do
    let(:action) do
      delete admin_admin_user_credential_path(admin, credential), as: :turbo_stream
    end

    let!(:credential) do
      admin.credentials.create!(nickname:    "test",
                                external_id: "asdf",
                                public_key:  "asdf",
                                sign_count:  0)
    end

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_admin_user_path(admin))
    end

    it "destroys an admin credential" do
      expect { action }.to(change { admin.credentials.reload.count }.by(-1))
    end
  end
end
