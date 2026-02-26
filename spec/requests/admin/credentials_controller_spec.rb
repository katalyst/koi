# frozen_string_literal: true

require "rails_helper"
require "webauthn/fake_client"

RSpec.describe Admin::CredentialsController do
  subject { action && response }

  let(:admin) { create(:admin_user) }
  let(:client) { WebAuthn::FakeClient.new(origin) }
  let(:origin) { "http://www.example.com" }

  before do
    WebAuthn.configuration.allowed_origins = [origin]
  end

  include_context "with admin session"

  describe "GET /admin/credentials/:id" do
    let(:action) do
      get admin_credential_path(credential), params: { admin_credential: credential_params }
    end
    let!(:credential) do
      admin.credentials.create!(nickname: "test", external_id: "asdf", public_key: "asdf")
    end

    let(:credential_params) { { nickname: "updated" } }

    it_behaves_like "requires admin"

    it { is_expected.to have_http_status(:ok).and(render_template(:show)) }
  end

  describe "GET /admin/profile/credentials/new" do
    let(:action) { get new_admin_profile_credential_path, as: :turbo_stream }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/profile/credentials" do
    let(:action) do
      get new_admin_profile_credential_path

      return unless response.successful?

      response = client.create(challenge: session[:registration_challenge]).to_json

      post admin_profile_credentials_path(admin),
           params: { admin_credential: { response: } },
           as:     :turbo_stream
    end

    it_behaves_like "requires admin"

    it { is_expected.to have_http_status(:see_other).and(redirect_to(admin_profile_path)) }

    it "creates an admin credential" do
      expect { action }.to(change { admin.credentials.reload.count }.by(1))
    end
  end

  describe "PATCH /admin/credentials/:id" do
    let(:action) do
      patch admin_credential_path(credential), params: { admin_credential: credential_params }
    end
    let!(:credential) do
      admin.credentials.create!(nickname: "test", external_id: "asdf", public_key: "asdf")
    end

    let(:credential_params) { { nickname: "updated" } }

    it_behaves_like "requires admin"

    it { is_expected.to have_http_status(:see_other).and(redirect_to(admin_profile_path)) }

    it "updates the credential" do
      expect { action }.to change { credential.reload.nickname }.to("updated")
    end
  end

  describe "DELETE /admin/credentials/:id" do
    let(:action) do
      delete admin_credential_path(credential), as: :turbo_stream
    end

    let!(:credential) do
      admin.credentials.create!(nickname:    "test",
                                external_id: "asdf",
                                public_key:  "asdf",
                                sign_count:  0)
    end

    it_behaves_like "requires admin"

    it "returns to the user page" do
      action
      expect(response).to have_http_status(:see_other).and(redirect_to(admin_profile_path))
    end

    it "destroys an admin credential" do
      expect { action }.to(change { admin.credentials.reload.count }.by(-1))
    end
  end
end
