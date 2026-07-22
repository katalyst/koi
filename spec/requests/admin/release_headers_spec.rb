# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin release headers" do
  before do
    allow(Koi::Release).to receive_messages(version: "1.2.3", revision: "abcdef1")
  end

  it "adds release headers to JSON responses" do
    post "/admin/tokens", as: :json, params: { grant_type: "invalid" }

    expect(response.headers.to_h).to include(
      "x-application-version"  => "1.2.3",
      "x-application-revision" => "abcdef1",
    )
  end

  context "with an HTML request" do
    include_context "with admin session"

    it "does not add release headers" do
      get "/admin/dashboard"

      expect(response.headers["X-Application-Version"]).to be_nil
    end
  end
end
