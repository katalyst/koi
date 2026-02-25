# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::TokensController do
  subject { action && response }

  describe "POST /admin/admin_users/:id/tokens" do
    let(:action) { post admin_admin_user_tokens_path(admin), as: :turbo_stream }
    let(:admin) { create(:admin) }

    include_context "with admin session"

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }

    it "renders the token" do
      action
      expect(response.body).to have_css("turbo-stream[action=replace][target='invite']")
    end
  end

  describe "GET /admin/session/tokens/:token" do
    let(:action) { get admin_session_token_path(token) }
    let(:admin) { create(:admin, password: "") }
    let(:token) { admin.generate_token_for(:password_reset) }

    it { is_expected.to be_successful }

    context "with a consumed token" do
      before do
        # force token generation
        token
        # simulate sign-in after token creation
        admin.update(current_sign_in_at: 1.second.from_now)
      end

      it { is_expected.to redirect_to(new_admin_session_path) }

      it "shows a flash message" do
        action
        expect(flash[:notice]).to match(/Token invalid or consumed already/)
      end
    end

    context "with invalid token" do
      let(:token) { "token" }

      it { is_expected.to redirect_to(new_admin_session_path) }

      it "shows a flash message" do
        action
        expect(flash[:notice]).to match(/Token invalid or consumed already/)
      end
    end
  end

  describe "PATCH /admin/session/tokens/:token" do
    let(:action) { patch admin_session_token_path(token) }
    let(:admin) { create(:admin, password: "") }
    let(:token) { admin.generate_token_for(:password_reset) }

    it { is_expected.to redirect_to(new_admin_admin_user_credential_path(admin)) }

    it "updates the admin login details" do
      expect { action }.to change { admin.reload.current_sign_in_at }.from(nil).to be_present
    end

    context "with a consumed token" do
      before do
        # force token generation
        token
        # simulate sign-in after token creation
        admin.update(current_sign_in_at: 1.second.from_now)
      end

      it { is_expected.to redirect_to(new_admin_session_path) }

      it "shows a flash message" do
        action
        expect(flash[:notice]).to match(/Token invalid or consumed already/)
      end
    end

    context "with invalid token" do
      let(:token) { "token" }

      it { is_expected.to redirect_to(new_admin_session_path) }

      it "shows a flash message" do
        action
        expect(flash[:notice]).to match(/Token invalid or consumed already/)
      end
    end
  end
end
