# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin authentication" do
  describe "GET /admin/dashboard" do
    subject { action && response }

    let(:action) { get "/admin/dashboard" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

    context "with a valid admin session" do
      include_context "with admin session"

      it { is_expected.to have_http_status(:success) }
    end

    context "with a valid bearer token" do
      let(:device_authorization) { create(:admin_device_authorization, :approved) }
      let(:action) do
        get "/admin/dashboard",
            headers: { "Authorization" => "Bearer #{device_authorization.generate_token_for(:api_access)}" }
      end

      it { is_expected.to have_http_status(:success) }

      it "does not create a session" do
        expect { action }.not_to change(Admin::Session, :count)
      end

      it "is rejected after the admin signs in again" do
        token = device_authorization.generate_token_for(:api_access)
        device_authorization.admin_user.update!(last_sign_in_at: 1.second.from_now)

        get "/admin/dashboard", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an invalid bearer token" do
      let(:action) { get "/admin/dashboard", headers: { "Authorization" => "Bearer invalid" } }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "with an expired session" do
      let(:admin) { create(:admin) }

      include_context "with admin session"

      before do
        admin.sessions.destroy_all
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

      it "clears the admin session" do
        action
        expect(cookies[:admin_session_id]).to be_blank
      end
    end
  end

  describe "GET //admin/dashboard" do
    subject { action && response }

    # Rails routes repeated slashes as if they were single slashes
    let(:action) { get "http://www.example.com//admin/dashboard" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

    context "with a valid admin session" do
      include_context "with admin session"

      it { is_expected.to have_http_status(:success) }
    end
  end

  describe "GET /admin/session/new" do
    subject { action && response }

    let(:action) { get "/admin/session/new" }

    it { is_expected.to have_http_status(:success) }
  end

  # Only the session resource is exempt from authentication, not every path that shares its prefix
  %w[/admin/sessions /admin/sessions/1 /admin/session_types /admin/session-types /admin/session.json].each do |path|
    describe "GET #{path}" do
      subject { action && response }

      let(:action) { get path }

      it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }
    end
  end

  describe "GET /administrator" do
    subject { action && response }

    let(:action) { get "/administrator" }

    around { |example| Koi.deprecator.silence { example.run } }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

    it "warns that the path will not be authenticated in Koi 6" do
      allow(Koi.deprecator).to receive(:warn)

      action

      expect(Koi.deprecator).to have_received(:warn).with(a_string_including('"/administrator"', "Koi 6.0"))
    end
  end

  describe "GET /admin" do
    it "does not warn" do
      allow(Koi.deprecator).to receive(:warn)

      get "/admin"

      expect(Koi.deprecator).not_to have_received(:warn)
    end
  end

  describe "GET /admin/guess" do
    subject { action && response }

    let(:action) { get "/admin/guess" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }
  end
end
