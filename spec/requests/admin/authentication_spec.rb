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
      let(:admin) { create(:admin) }
      let(:action) do
        get "/admin/dashboard", headers: { "Authorization" => "Bearer #{admin.generate_token_for(:api_access)}" }
      end

      it { is_expected.to have_http_status(:success) }

      it "does not create a session" do
        action
        expect(Admin::Session.count).to eq(0)
      end

      it "is rejected after the admin signs in again" do
        token = admin.generate_token_for(:api_access)
        admin.update!(current_sign_in_at: 1.second.from_now)

        get "/admin/dashboard", headers: { "Authorization" => "Bearer #{token}" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a valid bearer token and valid admin session cookie" do
      let(:admin) { create(:admin) }
      let(:action) do
        get "/admin/dashboard", headers: { "Authorization" => "Bearer #{admin.generate_token_for(:api_access)}" }
      end

      include_context "with admin session"

      it "does not clear the admin session cookie" do
        action

        expect(Array(response.headers["Set-Cookie"]).join("\n")).not_to include(
          "#{Koi::Controller::RecordsAuthentication::ADMIN_SESSION_COOKIE}=;",
        )
      end
    end

    context "with an invalid bearer token" do
      let(:action) { get "/admin/dashboard", headers: { "Authorization" => "Bearer invalid" } }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "with a deleted admin session" do
      let(:admin) { create(:admin) }

      include_context "with admin session"

      before do
        admin.sessions.sole.destroy!
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

      it "clears the admin session cookie" do
        action

        expect(Array(response.headers["Set-Cookie"]).join("\n")).to include(
          "#{Koi::Controller::RecordsAuthentication::ADMIN_SESSION_COOKIE}=",
        )
      end
    end

    context "with an archived admin user session" do
      let(:admin) { create(:admin) }

      include_context "with admin session"

      before do
        admin.archive!
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

      it "clears the admin session cookie" do
        action

        expect(Array(response.headers["Set-Cookie"]).join("\n")).to include(
          "#{Koi::Controller::RecordsAuthentication::ADMIN_SESSION_COOKIE}=",
        )
      end
    end
  end

  describe "GET /admin/guess" do
    subject { action && response }

    let(:action) { get "/admin/guess" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }
  end
end
