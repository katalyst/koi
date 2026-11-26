# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::AdminUsers::TokensController do
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

    it_behaves_like "with bearer token authentication" do
      it "fails with an authentication error" do
        post(admin_admin_user_tokens_path(admin), headers:, as: :turbo_stream)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with a role bearer token" do
      let(:device_authorization) { create(:admin_device_authorization, :admin_role) }
      let(:headers) { { "Authorization" => "Bearer #{device_authorization.generate_token_for(:api_access)}" } }

      def create_admin_session(_)
        nil # no-op, skip session creation
      end

      it "fails with an authentication error" do
        post(admin_admin_user_tokens_path(admin), headers:, as: :turbo_stream)

        expect(response).to have_http_status(:forbidden)
      end

      it "does not render a login link" do
        post(admin_admin_user_tokens_path(admin), headers:, as: :turbo_stream)

        expect(response.body).not_to include("/admin/session/tokens/")
      end
    end
  end
end
