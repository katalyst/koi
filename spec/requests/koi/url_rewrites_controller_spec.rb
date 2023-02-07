# frozen_string_literal: true

require "rails_helper"
require "support/requests/admin_examples"

RSpec.describe Koi::UrlRewritesController, type: :request do
  subject { action && response }

  let(:admin) { create :admin }

  include_context "with admin session"

  describe "GET /admin/url_rewrites" do
    let(:action) { get koi_engine.url_rewrites_path }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }

    context "with search" do
      let(:action) { get koi_engine.url_rewrites_path, params: { search: "dea" } }
      let(:found) { create(:url_rewrite, from: "/deals") }

      before do
        found
        create(:url_rewrite, from: "/offers")
      end

      it { is_expected.to be_successful }

      it "filters" do
        action
        expect(assigns(:url_rewrites)).to contain_exactly(found)
      end
    end
  end

  describe "GET /admin/url_rewrites/new" do
    let(:action) { get koi_engine.new_url_rewrite_path }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "POST /admin/url_rewrites" do
    let(:action) { post koi_engine.url_rewrites_path, params: { url_rewrite: url_rewrite_params } }
    let(:url_rewrite_params) { attributes_for :url_rewrite }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to(koi_engine.url_rewrite_path(assigns(:url_rewrite))) }

    it "creates an url rewrite" do
      expect { action }.to change(UrlRewrite, :count).by(1)
    end
  end

  describe "GET /admin/url_rewrites/:id" do
    let(:action) { get koi_engine.url_rewrite_path(url_rewrite) }
    let(:url_rewrite) { create :url_rewrite }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "GET /admin/url_rewrites/:id/edit" do
    let(:action) { get koi_engine.edit_url_rewrite_path(url_rewrite) }
    let(:url_rewrite) { create :url_rewrite }

    it_behaves_like "requires admin"

    it { is_expected.to be_successful }
  end

  describe "PATCH /admin/url_rewrites/:id" do
    let(:action) { patch koi_engine.url_rewrite_path(url_rewrite), params: { url_rewrite: url_rewrite_params } }
    let(:url_rewrite_params) { { to: "/offers" } }
    let(:url_rewrite) { create :url_rewrite, from: "/deals" }

    before { url_rewrite }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to(koi_engine.url_rewrite_path(url_rewrite)) }

    it "updates to" do
      expect { action && url_rewrite.reload }.to(change(url_rewrite, :to).to("/offers"))
    end

    context "with invalid params" do
      let(:url_rewrite_params) { { to: "" } }

      it { is_expected.to be_unprocessable }
    end
  end

  describe "DELETE /admin/url_rewrites/:id" do
    let(:action) { delete koi_engine.url_rewrite_path(url_rewrite) }
    let(:url_rewrite) { create :url_rewrite }

    before { url_rewrite }

    it_behaves_like "requires admin"

    it { is_expected.to redirect_to(koi_engine.url_rewrites_path) }

    it "removes an url rewrite" do
      expect { action }.to change(UrlRewrite, :count).by(-1)
    end
  end
end
