# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::AdminUsersController do
  let(:admin) { create(:admin) }

  include_context "with admin session"

  describe "GET /admin/admin_users" do
    let(:action) { get admin_admin_users_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/admin_users/new" do
    let(:action) { get new_admin_admin_user_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/admin_users" do
    let(:action) { post admin_admin_users_path, params: { admin: admin_params } }
    let(:admin_params) { attributes_for(:admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:found)
    end

    it "creates an admin" do
      expect { action }.to change(Admin::User, :count).by(1)
    end
  end

  describe "GET /admin/admin_users/:id" do
    let(:action) { get admin_admin_user_path(admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/admin_users/:id/edit" do
    let(:action) { get edit_admin_admin_user_path(admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/admin_users/:id" do
    let(:action) { patch admin_admin_user_path(admin), params: { admin: admin_params } }
    let(:admin_params) { attributes_for(:admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_admin_user_path(admin))
    end

    it "updates name" do
      expect { action }.to(change { admin.reload.name })
    end

    it "updates password" do
      expect { action }.not_to(change { admin.reload.password })
    end

    context "with empty password" do
      let(:admin_params) { { password: "" } }

      it "updates password" do
        expect { action }.not_to(change { admin.reload.password })
      end
    end

    context "with errors" do
      let(:admin_params) { { name: "" } }

      it "renders with errors" do
        action
        expect(response.body).to have_selector("#admin-name-error")
      end
    end
  end

  describe "DELETE /admin/admin_users/:id" do
    let(:action) { delete admin_admin_user_path(admin) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_admin_users_path)
    end
  end
end
