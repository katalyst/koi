# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/announcements/new" do
  before do
    render template: "admin/announcements/new", locals: { announcement: Announcement.new }
  end

  it { expect(rendered).to have_css("form[action=\"#{url_for([:admin, Announcement])}\"]") }
  it { expect(rendered).to have_button(text: "Create") }
end
