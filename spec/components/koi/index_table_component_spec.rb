# frozen_string_literal: true

require "rails_helper"

describe Koi::IndexTableComponent do
  subject(:component) { described_class.new(collection:) }

  let(:collection) { Katalyst::Tables::Collection::Base.new.apply(Post.strict_loading) }

  let(:post) { create(:post) }
  let(:format) { "text/html" }

  before do
    post
    with_controller_class Admin::PostsController do
      vc_test_request.headers["Accept"] = "text/html"
      vc_test_controller.response = instance_double(ActionDispatch::Response, media_type: "text/html")
      render_inline(component)
    end
  end

  it "renders collection" do
    expect(page).to have_link(post.name, href: vc_test_controller.polymorphic_path([:admin, post]))
  end

  it "doesn't render pagination" do
    expect(page).not_to have_css("#index-table-pagination")
  end

  context "with paginated collection" do
    let(:collection) { Admin::PostsController::Collection.new.apply(Post.strict_loading) }

    it "renders pagination" do
      expect(page).to have_css("#index-table-pagination")
    end
  end
end
