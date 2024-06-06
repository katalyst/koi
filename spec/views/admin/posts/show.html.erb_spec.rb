# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/posts/show" do
  let(:post) { create(:post) }

  before do
    render template: "admin/posts/show", locals: { post: }
  end

  it { expect(rendered).to have_css("th", text: "Name") }
  it { expect(rendered).to have_css("td", text: post.name) }
  it { expect(rendered).to have_css("th", text: "Title") }
  it { expect(rendered).to have_css("td", text: post.title) }
end
