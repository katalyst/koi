# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UrlRewritesController do
  let(:admin) { create(:admin) }
  let(:url_rewrite) { create(:url_rewrite) }

  include_context "with admin session"

  describe "GET /admin/url_rewrites" do
    let(:action) { get admin_url_rewrites_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/url_rewrites/new" do
    let(:action) { get new_admin_url_rewrite_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/url_rewrites" do
    let(:action) { post admin_url_rewrites_path, params: { url_rewrite: params } }
    let(:params) { attributes_for(:url_rewrite) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_url_rewrite_path(assigns(:url_rewrite)))
    end

    it "creates a url_rewrite" do
      expect { action }.to change(UrlRewrite, :count).by(1)
    end
  end

  describe "GET /admin/url_rewrites/:id" do
    let(:action) { get admin_url_rewrite_path(url_rewrite) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/url_rewrites/:id/edit" do
    let(:action) { get edit_admin_url_rewrite_path(url_rewrite) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/url_rewrites/:id" do
    let(:action) { patch admin_url_rewrite_path(url_rewrite), params: { url_rewrite: params } }
    let(:params) { attributes_for(:url_rewrite) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_url_rewrite_path(url_rewrite))
    end
  end

  describe "DELETE /admin/url_rewrites/:id" do
    let(:action) { delete admin_url_rewrite_path(url_rewrite) }
    let!(:url_rewrite) { create(:url_rewrite) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_url_rewrites_path)
    end

    it "deletes the url_rewrite" do
      expect { action }.to change(UrlRewrite, :count).by(-1)
    end
  end
end
