# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/announcements/edit" do
  let(:announcement) { create(:announcement) }

  before do
    controller.request.path_parameters[:id] = announcement.id
    render template: "admin/announcements/edit", locals: { announcement: }
  end

  it { expect(rendered).to have_css(%(form[action="/admin/announcements/#{announcement.id}"])) }
  it { expect(rendered).to have_field("Name") }
  it { expect(rendered).to have_field("Title") }
  it { expect(rendered).to have_button(text: "Update") }
end
