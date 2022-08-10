# frozen_string_literal: true

require "rails_helper"
require "support/requests/admin_examples"

RSpec.describe Koi::NavigationLinksController, type: :request do
  let(:subject) { action && response }
  let(:admin) { create :admin }
  let(:navigation_menu) { create :katalyst_navigation_menu }

  include_context "with admin session"

  describe "GET /admin/navigations/:slug/links" do
    let(:action) { get koi_engine.navigation_menu_links_path(navigation_menu) }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "GET /admin/navigations/:slug/links/new" do
    let(:action) { get koi_engine.new_navigation_menu_link_path(navigation_menu) }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "POST /admin/navigations/:slug/links/" do
    let(:action) do
      post koi_engine.navigation_menu_links_path(navigation_menu),
           params: { link: link_params },
           as:     :turbo_stream
    end
    let(:link_params) { attributes_for(:katalyst_navigation_link) }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }

    it { expect { action }.to change(Katalyst::Navigation::Link, :count).by(1) }

    context "with invalid params" do
      let(:link_params) { { title: "" } }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(Katalyst::Navigation::Link, :count) }
    end
  end

  describe "GET /admin/navigations/:slug/links/:id" do
    let(:action) { get koi_engine.navigation_menu_link_path(navigation_menu, navigation_link) }
    let(:navigation_link) { create :katalyst_navigation_link, menu: navigation_menu }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "GET /admin/navigations/:slug/links/:id/edit" do
    let(:action) { get koi_engine.edit_navigation_menu_link_path(navigation_menu, navigation_link) }
    let(:navigation_link) { create :katalyst_navigation_link, menu: navigation_menu }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "PATCH /admin/navigations/:slug/links/:id" do
    let(:action) do
      patch koi_engine.navigation_menu_link_path(navigation_menu, navigation_link),
            params: { link: link_params },
            as:     :turbo_stream
    end
    let(:title) { Faker::Beer.name }
    let!(:navigation_link) { create :katalyst_navigation_link, menu: navigation_menu, title: title }
    let(:link_params) { { title: "A new level" } }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }

    it { expect { action }.not_to change(navigation_link, :title) }
    it { expect { action }.to change(Katalyst::Navigation::Link, :count).by(1) }

    it "sets title in the new link version" do
      action
      expect(Katalyst::Navigation::Link.last.title).to eq("A new level")
    end

    context "with invalid params" do
      let(:link_params) { { title: "" } }

      it { is_expected.to be_unprocessable }
    end
  end
end
