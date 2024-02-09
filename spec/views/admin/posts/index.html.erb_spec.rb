# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/posts/index" do
  include Pagy::Backend
  include Katalyst::Tables::Backend

  let!(:posts) { create_list(:post, 2) }

  before do
    view.extend(Pagy::Frontend)

    collection = Admin::PostsController::Collection.new.apply(Post.all)
    table      = Koi::Tables::TableComponent.new(collection:, id: "index-table")

    # Workaround for https://github.com/rspec/rspec-rails/issues/2729
    view.lookup_context.prefixes.prepend "admin/posts"

    render locals: { collection:, table: }
  end

  it { expect(rendered).to have_css("th", text: "Name") }
  it { expect(rendered).to have_link(posts.first.name, href: admin_post_path(posts.first)) }
  it { expect(rendered).to have_css("td", text: posts.first.name) }
  it { expect(rendered).to have_css("th", text: "Title") }
  it { expect(rendered).to have_css("td", text: posts.first.title) }
end
