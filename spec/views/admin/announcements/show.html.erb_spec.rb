# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/announcements/show" do
  let(:announcement) { create(:announcement) }

  before do
    render template: "admin/announcements/show", locals: { announcement: }
  end

  it { expect(rendered).to have_css("th", text: "Name") }
  it { expect(rendered).to have_css("td", text: announcement.name) }
  it { expect(rendered).to have_css("th", text: "Title") }
  it { expect(rendered).to have_css("td", text: announcement.title) }
end
