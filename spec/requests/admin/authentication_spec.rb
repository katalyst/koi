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
        device_authorization.admin_user.update!(current_sign_in_at: 1.second.from_now)

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

  describe "GET /admin/guess" do
    subject { action && response }

    let(:action) { get "/admin/guess" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }
  end
end
