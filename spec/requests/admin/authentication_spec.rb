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
        expect(session[:admin_user_id]).to be_nil
      end

      it "is rejected after the admin signs in again" do
        token = admin.generate_token_for(:api_access)
        admin.update!(current_sign_in_at: 1.second.from_now)

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
        admin.update!(last_sign_out_at: Time.current)
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

      it "clears the admin session" do
        action
        aggregate_failures do
          expect(session[:admin_user_id]).to be_nil
          expect(session[:admin_user_signed_in_at]).to be_nil
        end
      end
    end

    context "with a session missing its sign in timestamp" do
      include_context "with admin session"

      before do
        allow_any_instance_of(Koi::Middleware::AdminAuthentication).to receive(:session_signed_in_at).and_return(nil)
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

      it "clears the admin session" do
        action
        aggregate_failures do
          expect(session[:admin_user_id]).to be_nil
          expect(session[:admin_user_signed_in_at]).to be_nil
        end
      end
    end
  end

  describe "GET /admin/guess" do
    subject { action && response }

    let(:action) { get "/admin/guess" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }
  end
end
