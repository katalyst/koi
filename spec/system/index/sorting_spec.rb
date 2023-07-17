# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/sorting" do
  let(:admin) { create(:admin) }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_button "Log in"

    %i[first second third].map do |n|
      create(:post, name: n, title: n.to_s.titleize)
    end
  end

  it "supports sorting" do
    visit "/admin/posts"

    expect(page).to have_css("tr:first-child", text: "first")

    click_on "Title"

    expect(page).to have_current_path("/admin/posts?sort=title+asc")
    expect(page).to have_css("tr:first-child", text: "first")

    click_on "Title"

    expect(page).to have_current_path("/admin/posts?sort=title+desc")
    expect(page).to have_css("tr:first-child", text: "third")
  end

  xit "shows the default sort" do
    visit "/admin/posts"

    expect(page).to have_css("thead th[data-sort='asc'] a[href$='name+desc']")
  end

  context "with a sort applied" do
    it "shows the sort" do
      visit "/admin/posts?sort=title+asc"

      expect(page).to have_css("thead th[data-sort='asc'] a[href$='title+desc']")
    end
  end

  context "when a new filter is applied" do
    xit "retains sorting" do
      visit "/admin/posts?sort=title+asc"

      fill_in "Search", with: "first"

      expect(page).to have_current_path("/admin/posts?sort=title+asc&search=first")
    end
  end

  context "when paginating" do
    it "retains sorting" do
      create_list(:post, 25)

      visit "/admin/posts?sort=title+asc"

      click_on "Next"

      expect(page).to have_current_path("/admin/posts?sort=title+asc&page=2")
    end
  end
end
