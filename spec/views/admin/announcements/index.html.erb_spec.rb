# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/announcements/index" do
  include Pagy::Backend
  include Katalyst::Tables::Backend

  let!(:announcements) { create_list(:announcement, 2) }

  before do
    view.extend(Pagy::Frontend)

    collection = Admin::AnnouncementsController::Collection.new.apply(Announcement.all)

    # Workaround for https://github.com/rspec/rspec-rails/issues/2729
    view.lookup_context.prefixes.prepend "admin/announcements"

    allow(view).to receive(:default_table_component_class).and_return(Koi::TableComponent)

    render locals: { collection: }
  end

  it { expect(rendered).to have_css("th", text: "Name") }
  it { expect(rendered).to have_link(announcements.first.name, href: admin_announcement_path(announcements.first)) }
  it { expect(rendered).to have_css("td", text: announcements.first.name) }
  it { expect(rendered).to have_css("th", text: "Title") }
  it { expect(rendered).to have_css("td", text: announcements.first.title) }
end
