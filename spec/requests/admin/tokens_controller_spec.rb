# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::TokensController do
  subject { action && response }

  def jwt_token(**payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  describe "GET /admin/token/:token" do
    let(:action) { get admin_token_path(token) }
    let(:admin) { create(:admin, password: "") }
    let(:token) { jwt_token(admin_id: admin.id, exp: 5.seconds.from_now.to_i, iat: Time.now.to_i) }

    it { is_expected.to be_successful }

    context "with used token" do
      let(:admin) { create(:admin, last_sign_in_at: Time.now) }
      let(:token) { jwt_token(admin_id: admin.id, exp: 5.seconds.from_now.to_i, iat: 1.hour.ago.to_i) }

      it { is_expected.to redirect_to(new_admin_session_path) }

      it "shows a flash message" do
        action
        expect(flash[:notice]).to match(/token already used/)
      end
    end

    context "with invalid token" do
      let(:token) { "token" }

      it { is_expected.to redirect_to(new_admin_session_path) }

      it "shows a flash message" do
        action
        expect(flash[:notice]).to match(/invalid token/)
      end
    end
  end

  describe "POST /admin/admin_users/:id/invite" do
    let(:action) { post invite_admin_admin_user_path(admin), as: :turbo_stream }
    let(:admin) { create(:admin) }

    include_context "with admin session"

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }

    it "renders the token" do
      action
      expect(response.body).to have_css("turbo-stream[action=replace][target='invite']")
    end
  end

  describe "POST /admin/admin_users/:id/accept" do
    let(:action) { post accept_admin_admin_user_path(admin), params: { commit:, token: } }
    let(:admin) { create(:admin, password: "") }
    let(:commit) { "commit" }
    let(:token) { jwt_token(admin_id: admin.id, exp: 5.seconds.from_now.to_i, iat: Time.now.to_i) }

    it { is_expected.to redirect_to(admin_admin_user_path(admin)) }

    it "updates the admin login details" do
      expect { action }.to change { admin.reload.current_sign_in_at }.from(nil).to be_present
    end

    context "when admin is signed in" do
      let(:admin) { create(:admin) }

      include_context "with admin session"

      it { is_expected.to redirect_to(admin_dashboard_path) }
    end
  end
end
