# frozen_string_literal: true

require "rails_helper"
require "support/requests/admin_examples"

RSpec.describe "Admins", type: :request do
  let(:admin) { create :admin }

  include_context "with admin session"

  describe "GET /admin/site_users" do
    let(:action) { get koi_engine.admins_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/site_users/new" do
    let(:action) { get koi_engine.new_admin_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/site_users" do
    let(:action) { post koi_engine.admins_path, params: { admin: admin_params } }
    let(:admin_params) { attributes_for :admin }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(koi_engine.admins_path)
    end

    it "creates an admin" do
      expect { action }.to change(AdminUser, :count).by(1)
    end
  end

  describe "GET /admin/site_users/:id" do
    let(:action) { get koi_engine.admin_path(admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/site_users/:id/edit" do
    let(:action) { get koi_engine.edit_admin_path(admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/site_users/:id" do
    let(:action) { patch koi_engine.admin_path(admin), params: { admin: admin_params } }
    let(:admin_params) { attributes_for :admin }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(koi_engine.admins_path)
    end

    it "updates name" do
      expect { action }.to(change { admin.reload.first_name })
    end

    it "updates password" do
      expect { action }.not_to(change { admin.reload.password })
    end

    context "with empty password" do
      let(:admin_params) { { password: "", password_confirmation: "" } }

      it "updates password" do
        expect { action }.not_to(change { admin.reload.password })
      end
    end

    context "with errors" do
      let(:admin_params) { { first_name: "" } }

      it "renders with errors" do
        action
        expect(response.body).to have_selector(".admin_first_name.error")
      end
    end
  end

  describe "DELETE /admin/site_users/:id" do
    let(:action) { delete koi_engine.admin_path(admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(koi_engine.admins_path)
    end
  end
end
