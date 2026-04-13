# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin authentication" do
  describe "GET /admin/dashboard" do
    subject { action && response }

    let(:action) { get "/admin/dashboard" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }

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
    end

    context "with an invalid bearer token" do
      let(:action) { get "/admin/dashboard", headers: { "Authorization" => "Bearer invalid" } }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end

  describe "GET /admin/guess" do
    subject { action && response }

    let(:action) { get "/admin/guess" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }
  end
end
