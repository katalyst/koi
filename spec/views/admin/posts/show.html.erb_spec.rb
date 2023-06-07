# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/posts/show" do
  let(:post) { create(:post) }

  before do
    render template: "admin/posts/show", locals: { post: }
  end

  it { expect(rendered).to have_css("dt", text: "Name") }
  it { expect(rendered).to have_css("dd", text: post.name) }
  it { expect(rendered).to have_css("dt", text: "Title") }
  it { expect(rendered).to have_css("dd", text: post.title) }
end
