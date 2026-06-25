# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::FeatureFlagsController do
  let(:admin) { create(:admin) }
  let(:key) { "my_feature" }

  include_context "with admin session"

  before { Flipper.add(key) }

  describe "GET /admin/feature_flags" do
    let(:action) { get admin_feature_flags_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/feature_flags/new" do
    let(:action) { get new_admin_feature_flag_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/feature_flags" do
    let(:action) { post admin_feature_flags_path, params: { feature_flag: { key: "new_feature" } } }

    it_behaves_like "requires admin"

    it "redirects to the created feature flag" do
      action
      expect(response).to redirect_to(admin_feature_flag_path("new_feature"))
    end

    context "when the name is blank" do
      let(:action) { post admin_feature_flags_path, params: { feature_flag: { key: "" } } }

      it "re-renders the form" do
        action
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /admin/feature_flags/:id" do
    let(:action) { get admin_feature_flag_path(key) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/feature_flags/:id" do
    let(:action) { patch admin_feature_flag_path(key), params: { feature_flag: { state: "on" } } }

    it_behaves_like "requires admin"

    it "redirects to the index" do
      action
      expect(response).to redirect_to(admin_feature_flags_path)
    end
  end

  describe "DELETE /admin/feature_flags/:id" do
    let(:action) { delete admin_feature_flag_path(key) }

    it_behaves_like "requires admin"

    it "redirects to the index" do
      action
      expect(response).to redirect_to(admin_feature_flags_path)
    end
  end
end
