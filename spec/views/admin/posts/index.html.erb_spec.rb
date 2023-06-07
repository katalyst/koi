# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/posts/index" do
  include Pagy::Backend
  include Katalyst::Tables::Backend

  let!(:posts) { create_list(:post, 2) }

  before do
    view.extend(Pagy::Frontend)

    posts       = Post.all
    sort, posts = table_sort(posts)
    pagy, posts = pagy(posts)

    render template: "admin/posts/index", locals: { posts:, sort:, pagy: }
  end

  it { expect(rendered).to have_css("td", text: posts.first.name) }
  it { expect(rendered).to have_css("td", text: posts.first.title) }
end
