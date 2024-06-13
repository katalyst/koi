# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/posts/new" do
  before do
    render template: "admin/posts/new", locals: { post: Post.new }
  end

  it { expect(rendered).to have_css("form[action=\"#{url_for([:admin, Post])}\"]") }
  it { expect(rendered).to have_button(text: "Save") }
end
