# frozen_string_literal: true

require "rails_helper"
require "support/requests/admin_examples"

RSpec.describe Koi::Navigation::LinksController, type: :request do
  let(:subject) { action && response }
  let(:admin) { create :admin }
  let(:navigation_menu) { create :navigation_menu }

  include_context "with admin session"

  describe "GET /admin/navigations/:slug/links" do
    let(:action) { get koi_engine.navigation_links_path(navigation_menu) }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "GET /admin/navigations/:slug/links/new" do
    let(:action) { get koi_engine.new_navigation_link_path(navigation_menu) }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "POST /admin/navigations/:slug/links/" do
    let(:action) { post koi_engine.navigation_links_path(navigation_menu), params: params }
    let(:params) { { link: attributes_for(:navigation_link) } }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to koi_engine.navigation_links_path(navigation_menu) }

    it { expect { action }.to change(NavigationLink, :count).by(1) }

    context "with invalid params" do
      let(:params) { { link: { title: "" } } }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(NavigationLink, :count) }
    end
  end

  describe "GET /admin/navigations/:slug/links/:id" do
    let(:action) { get koi_engine.navigation_link_path(navigation_menu, navigation_link) }
    let(:navigation_link) { create :navigation_link, navigation_menu: navigation_menu }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "GET /admin/navigations/:slug/links/:id/edit" do
    let(:action) { get koi_engine.edit_navigation_link_path(navigation_menu, navigation_link) }
    let(:navigation_link) { create :navigation_link, navigation_menu: navigation_menu }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "PATCH /admin/navigations/:slug/links/:id" do
    let(:action) { patch koi_engine.navigation_link_path(navigation_menu, navigation_link), params: params }
    let(:navigation_link) { create :navigation_link, navigation_menu: navigation_menu }
    let(:params) { { link: { title: "A new level" } } }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to koi_engine.navigation_link_path(navigation_menu, navigation_link) }
    it { expect { action }.to change { navigation_link.reload.title }.to("A new level") }

    context "with invalid params" do
      let(:params) { { link: { title: "" } } }

      it { is_expected.to be_unprocessable }
    end
  end

  describe "DELETE /admin/navigations/:slug/links/:id" do
    let(:action) { delete koi_engine.navigation_link_path(navigation_menu, navigation_link) }
    let!(:navigation_link) { create :navigation_link, navigation_menu: navigation_menu }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to(koi_engine.navigation_links_path(navigation_menu)) }

    it "removes the record" do
      expect { action }.to change { navigation_menu.reload.navigation_links.count }.by(-1)
    end
  end
end
