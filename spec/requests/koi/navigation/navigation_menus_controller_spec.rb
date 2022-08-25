# frozen_string_literal: true

require "rails_helper"
require "support/requests/admin_examples"

RSpec.describe Koi::NavigationMenusController, type: :request do
  let(:subject) { action && response }
  let(:admin) { create :admin }

  include_context "with admin session"

  shared_context "with draft" do
    before do
      navigation_menu.update!(navigation_links_attributes: [{ id: 1, depth: 0, index: 0 }])
    end
  end

  describe "GET /admin/navigation_menus" do
    let(:action) { get koi_engine.navigation_menus_path }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "GET /admin/navigation_menus/new" do
    let(:action) { get koi_engine.new_navigation_menu_path }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "POST /admin/navigation_menus" do
    let(:action) { post koi_engine.navigation_menus_path, params: {navigation_menu: menu_params} }
    let(:menu_params) {  attributes_for(:navigation_menu) }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to(koi_engine.navigation_menu_path(assigns(:menu))) }

    it { expect { action }.to change(NavigationMenu, :count).by(1) }

    context "with invalid params" do
      let(:menu_params) { { title: "" } }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(NavigationMenu, :count) }
    end
  end

  describe "GET /admin/navigation_menus/:slug" do
    let(:action) { get koi_engine.navigation_menu_path(navigation_menu) }
    let(:navigation_menu) { create :navigation_menu }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "PATCH /admin/navigations/:slug" do
    let(:action) { patch koi_engine.navigation_menu_path(navigation_menu), params: params }
    let(:navigation_menu) { create :navigation_menu }
    let(:menu_params) do
      {
        navigation_links_attributes: [
          { id: 1, depth: 0, index: 0 },
          { id: 2, depth: 1, index: 1 },
        ],
      }
    end
    let(:params) { { navigation_menu: menu_params, commit: commit } }
    let(:commit) { "discard" }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to(koi_engine.navigation_menu_path(navigation_menu)) }

    context "save" do
      let(:commit) { "save" }

      it { expect { action }.to change { navigation_menu.reload.state }.from(:published).to(:draft) }
    end

    context "publish" do
      let(:commit) { "publish" }

      include_context "with draft"

      it { expect { action }.to change { navigation_menu.reload.state }.from(:draft).to(:published) }
    end

    context "revert" do
      let(:commit) { "revert" }

      include_context "with draft"

      it { expect { action }.to change { navigation_menu.reload.state }.from(:draft).to(:published) }
    end
  end
end
