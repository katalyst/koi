# frozen_string_literal: true

require "rails_helper"

RSpec.describe WellKnownsController do
  let(:well_known) { create(:well_known) }

  describe "GET /.well-known/:name" do
    let(:action) { get "/.well-known/#{well_known.name}" }

    it "renders successfully" do
      action
      expect(response).to have_http_status(:success)
    end

    it "renders content type" do
      action
      expect(response.headers).to include("content-type" => "text/plain; charset=utf-8")
    end

    it "renders content" do
      action
      expect(response.body).to eq(well_known.content)
    end

    context "with a json response" do
      let(:well_known) { create(:well_known, content_type: :json, content: "{ 'hello': 'world' }") }

      it "renders content type" do
        action
        expect(response.headers).to include("content-type" => "application/json; charset=utf-8")
      end

      it "renders content" do
        action
        expect(response.body).to eq(well_known.content)
      end
    end
  end
end
