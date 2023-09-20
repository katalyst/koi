# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::BannersController do
  let(:model) { create(:banner) }

  include_context "with admin session"

  describe "GET /admin/banners" do
    let(:action) { get polymorphic_path([:admin, Banner]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end

    context "with a large collection" do
      before { create_list(:banner, 25) }

      it "does not paginate the collection" do
        action
        expect(response.body).to have_selector("tbody tr", count: 25)
      end
    end

    context "with ordinals" do
      let(:action) { get polymorphic_path([:admin, Banner]) }

      before do
        create(:banner, name: "first", ordinal: 1)
        create(:banner, name: "second", ordinal: 0)
      end

      it "finds first in second place" do
        action
        expect(response.body).to have_selector("tbody tr + tr td", text: "first")
      end
    end

    context "with search parameter" do
      let(:action) { get polymorphic_path([:admin, Banner], search: "first") }

      before do
        create(:banner, name: "first")
        create(:banner, name: "second")
      end

      it "finds the needle" do
        action
        expect(response.body).to have_selector("table td", text: "first")
      end

      it "removes the chaff" do
        action
        expect(response.body).not_to have_selector("table td", text: "second")
      end
    end
  end

  describe "GET /admin/banners/new" do
    let(:action) { get new_polymorphic_path([:admin, Banner]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/banners" do
    let(:action) { post polymorphic_path([:admin, Banner]), params: { banner: params } }
    let(:params) { attributes_for(:banner) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to([:admin, assigns(:banner)])
    end

    it "creates a banner" do
      expect { action }.to change(Banner, :count).by(1)
    end
  end

  describe "GET /admin/banners/:id" do
    let(:action) { get polymorphic_path([:admin, model]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/banners/:id/edit" do
    let(:action) { get edit_polymorphic_path([:admin, model]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/banners/:id" do
    let(:action) { patch polymorphic_path([:admin, model]), params: { banner: params } }
    let(:params) { attributes_for(:banner) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(polymorphic_path([:admin, model]))
    end
  end

  describe "PATCH /admin/banners/order" do
    let(:action) { patch polymorphic_path([:order, :admin, Banner]), params: { order: params } }
    let(:params) { { banners: { first.id => { ordinal: 1 }, second.id => { ordinal: 0 } } } }
    let(:first) { create(:banner, name: "first", ordinal: 0) }
    let(:second) { create(:banner, name: "second", ordinal: 1) }

    it_behaves_like "requires admin"

    it "redirects back" do
      action
      expect(response).to redirect_to(polymorphic_path([:admin, Banner]))
    end

    it "updates ordinals" do
      expect { action }.to change(Banner, :first).to have_attributes(name: "second")
    end
  end

  describe "DELETE /admin/banners/:id" do
    let(:action) { delete polymorphic_path([:admin, model]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(polymorphic_path([:admin, Banner]))
    end
  end
end
