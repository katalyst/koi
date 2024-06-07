# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::FiltersController do
  subject { action && response }

  let(:admin) { create(:admin) }

  include_context "with admin session"

  describe "GET /admin/filters/:model" do
    let(:action) { get admin_filter_path(Banner.name) }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
    it { is_expected.to render_template(:attributes) }

    it "renders a link for the name attribute" do
      action

      expect(response.body).to have_link("Name", href: admin_filter_path(Banner.name, key: "name"))
    end

    context "when an attribute is selected" do
      let(:action) { get admin_filter_path(Banner.name, key: "name") }

      it { is_expected.to be_successful }
      it { is_expected.to render_template(:values) }

      it "renders a link for some example values from the database" do
        banner = create(:banner)

        action

        expect(response.body).to have_link(banner.name, href: admin_filter_path(Banner.name))
      end
    end
  end
end
