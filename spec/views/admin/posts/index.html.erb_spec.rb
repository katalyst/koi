# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/posts/index" do
  include Pagy::Backend
  include Katalyst::Tables::Backend

  let!(:posts) { create_list(:post, 2) }

  before do
    view.extend(Pagy::Frontend)

    posts = Admin::PostsController::Collection.new(default_sort: :name).apply(Post.all)

    render template: "admin/posts/index", locals: { posts: }
  end

  it { expect(rendered).to have_css("th", text: "Name") }
  it { expect(rendered).to have_css("td", text: posts.first.name) }
  it { expect(rendered).to have_css("th", text: "Title") }
  it { expect(rendered).to have_css("td", text: posts.first.title) }
end
