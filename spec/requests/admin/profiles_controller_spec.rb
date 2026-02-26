# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ProfilesController do
  let(:admin) { create(:admin_user) }

  include_context "with admin session"

  describe "GET /admin/profile" do
    let(:action) { get admin_profile_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/profile/edit" do
    let(:action) { get edit_admin_profile_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/profile" do
    let(:action) { patch admin_profile_path, params: { admin_user: admin_params } }
    let(:admin_params) { attributes_for(:admin_user) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_profile_path)
    end

    it "updates name" do
      expect { action }.to(change { admin.reload.name })
    end

    it "updates password" do
      expect { action }.to(change { admin.reload.password_digest })
    end

    context "with empty password" do
      let(:admin_params) { { password: "" } }

      it "updates password" do
        expect { action }.not_to(change { admin.reload.password_digest })
      end
    end

    context "with errors" do
      let(:admin_params) { { name: "" } }

      it "renders with errors" do
        action
        expect(response.body).to have_css("#admin-user-name-error")
      end
    end
  end
end
