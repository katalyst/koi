# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::WellKnownsController do
  let(:admin) { create(:admin) }
  let(:well_known) { create(:well_known) }

  include_context "with admin session"

  describe "GET /admin/well_knowns" do
    let(:action) { get admin_well_knowns_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/well_knowns/new" do
    let(:action) { get new_admin_well_known_path }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/well_knowns" do
    let(:action) { post admin_well_knowns_path, params: { well_known: params } }
    let(:params) { attributes_for(:well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_well_known_path(assigns(:well_known)))
    end

    it "creates a well_known" do
      expect { action }.to change(WellKnown, :count).by(1)
    end
  end

  describe "GET /admin/well_knowns/:id" do
    let(:action) { get admin_well_known_path(well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/well_knowns/:id/edit" do
    let(:action) { get edit_admin_well_known_path(well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/well_knowns/:id" do
    let(:action) { patch admin_well_known_path(well_known), params: { well_known: params } }
    let(:params) { attributes_for(:well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_well_known_path(well_known))
    end
  end

  describe "DELETE /admin/well_knowns/:id" do
    let(:action) { delete admin_well_known_path(well_known) }
    let!(:well_known) { create(:well_known) }

    it_behaves_like "requires admin"

    it "renders successfully" do
      action
      expect(response).to redirect_to(admin_well_knowns_path)
    end

    it "deletes the well_known" do
      expect { action }.to change(WellKnown, :count).by(-1)
    end
  end
end
