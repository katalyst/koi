# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::WellKnownsController do
  let(:admin) { create(:admin) }
  let(:model) { create(:well_known) }

  include_context "with admin session"

  describe "GET /admin/well_knowns" do
    let(:action) { get polymorphic_path([:admin, WellKnown]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end

    context "with a large collection" do
      before { create_list(:well_known, 25) } # rubocop:disable FactoryBot/ExcessiveCreateList

      it "paginates the collection" do
        action
        expect(response.body).to have_css("tbody tr", count: 20)
      end
    end

    context "with sort parameter" do
      let(:action) { get polymorphic_path([:admin, WellKnown], sort: "name desc") }

      before do
        create(:well_known, name: "first")
        create(:well_known, name: "second")
      end

      it "finds first in second place" do
        action
        expect(response.body).to have_css("tbody tr + tr td", text: "first")
      end
    end

    context "with search parameter" do
      let(:action) { get polymorphic_path([:admin, WellKnown], search: "first") }

      before do
        create(:well_known, name: "first")
        create(:well_known, name: "second")
      end

      it "finds the needle" do
        action
        expect(response.body).to have_css("table td", text: "first")
      end

      it "removes the chaff" do
        action
        expect(response.body).to have_no_css("table td", text: "second")
      end
    end
  end

  describe "GET /admin/well_knowns/new" do
    let(:action) { get new_polymorphic_path([:admin, WellKnown]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/well_knowns" do
    let(:action) { post polymorphic_path([:admin, WellKnown]), params: { well_known: params } }
    let(:params) { attributes_for(:well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to([:admin, assigns(:well_known)])
    end

    it "creates a well_known" do
      expect { action }.to change(WellKnown, :count).by(1)
    end
  end

  describe "GET /admin/well_knowns/:id" do
    let(:action) { get polymorphic_path([:admin, model]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/well_knowns/:id/edit" do
    let(:action) { get edit_polymorphic_path([:admin, model]) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/well_knowns/:id" do
    let(:action) { patch polymorphic_path([:admin, model]), params: { well_known: params } }
    let(:params) { attributes_for(:well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(polymorphic_path([:admin, model]))
    end
  end

  describe "DELETE /admin/well_knowns/:id" do
    let(:action) { delete polymorphic_path([:admin, model]) }
    let!(:model) { create(:well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(polymorphic_path([:admin, WellKnown]))
    end

    it "deletes the well_known" do
      expect { action }.to change(WellKnown, :count).by(-1)
    end
  end
end
