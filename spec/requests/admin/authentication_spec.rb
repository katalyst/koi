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

    context "with a session created before the user's last logout" do
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
  end

  describe "GET /admin/guess" do
    subject { action && response }

    let(:action) { get "/admin/guess" }

    it { is_expected.to have_http_status(:see_other).and(redirect_to("/admin/session/new")) }
  end
end
