# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/pagination" do
  let(:admin) { create(:admin) }
  let(:announcements) { Announcement.order(name: :asc) }

  before do
    create_list(:announcement, 25) # rubocop:disable FactoryBot/ExcessiveCreateList

    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"
  end

  context "when there are more than 20 results" do
    it "supports pagination" do
      visit "/admin/announcements"

      expect(page).to have_css("td", text: announcements.first.title)

      click_on "Next"

      expect(page).to have_css("td", text: announcements.last.title)
    end
  end

  context "when a new filter is applied" do
    let(:search) { announcements.first.title.split(/\W+/).first }

    it "clears pagination" do
      visit "/admin/announcements?page=2"

      fill_in("Search", with: search).click
      click_on "Apply"

      expect(page).to have_current_path("/admin/announcements?q=#{search}")
    end
  end

  context "when a new sort is applied" do
    it "clears pagination" do
      visit "/admin/announcements?page=2"

      click_on "Title"

      expect(page).to have_current_path("/admin/announcements?sort=title+asc")
    end
  end
end
