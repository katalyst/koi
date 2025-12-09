# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/filtering" do
  let(:admin) { create(:admin) }
  let(:query) { "first" }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"

    %i[first second third].map do |n|
      create(:announcement, name: n, title: n.to_s.titleize)
    end
  end

  it "applies filters" do
    visit "/admin/announcements"

    fill_in("Search", with: query).click
    click_on "Apply"

    expect(page).to have_current_path("/admin/announcements?q=#{query}")
    expect(page).to have_css("td", text: "first")
    expect(page).to have_no_css("td", text: "third")
  end

  it "clears filters" do
    visit "/admin/announcements?q=#{query}"

    expect(page).to have_css("[name=q]", text: query)
    expect(page).to have_no_css("td", text: "third")

    fill_in("Search", with: "").click
    click_on "Apply"

    expect(page).to have_current_path("/admin/announcements")
    expect(page).to have_css("td", text: "third")
  end

  context "when there are no results" do
    it "shows a placeholder message" do
      visit "/admin/announcements?q=xxxxxx"

      expect(page).to have_css("caption", text: "No announcements found.")
    end
  end

  context "when paginating" do
    it "retains filter" do
      create_list(:announcement, 25, name: "first", title: "First") # rubocop:disable FactoryBot/ExcessiveCreateList

      visit "/admin/announcements?q=#{query}"

      click_on "Next"

      expect(page).to have_current_path("/admin/announcements?q=#{query}&search=#{query}&page=2")
      expect(page).to have_css("[name=q]", text: query)
    end
  end

  context "when sorting" do
    it "retains filter" do
      visit "/admin/announcements?q=#{query}"

      click_on "Title"

      expect(page).to have_current_path("/admin/announcements?q=#{query}&sort=title+asc")
      expect(page).to have_css("[name=q]", text: query)
    end
  end

  context "with history navigation" do
    it "restores search state" do
      visit "/admin/announcements"

      fill_in("Search", with: query).click
      click_on "Apply"

      expect(page).to have_current_path("/admin/announcements?q=#{query}")

      click_on "Koi" # leave the page with turbo

      expect(page).to have_css("h1", text: "Dashboard")

      page.go_back

      expect(page).to have_current_path("/admin/announcements?q=#{query}")
      expect(find("[name=q]").value).to eql(query)
    end
  end
end
