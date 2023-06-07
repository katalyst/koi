# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/posts/edit" do
  let(:post) { create(:post) }

  before do
    controller.request.path_parameters[:id] = post.id
    render template: "admin/posts/edit", locals: { post: }
  end

  it { expect(rendered).to have_selector(%(form[action="/admin/posts/#{post.id}"])) }
  it { expect(rendered).to have_field("Name") }
  it { expect(rendered).to have_field("Title") }
  it { expect(rendered).to have_button(text: "Save") }
  it { expect(rendered).to have_link(text: "Delete") }
end
