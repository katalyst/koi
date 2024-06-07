# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/filtering" do
  let(:admin) { create(:admin) }
  let(:query) { "first" }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_on "Log in"

    %i[first second third].map do |n|
      create(:post, name: n, title: n.to_s.titleize)
    end
  end

  it "supports untagged text filtering" do
    visit "/admin/posts"

    fill_in "Search", with: query

    expect(page).to have_current_path("/admin/posts?search=#{query}")
    expect(page).to have_css("td", text: "first")
    expect(page).not_to have_css("td", text: "third")
  end

  it "supports tagged text filters" do
    visit "/admin/posts"

    find("main input[type=search]").click
    click_on("Title")
    find("main input[type=search]").native.send_keys(query)

    expect(page).to have_current_path("/admin/posts?title=#{query}")
    expect(page).to have_css("td", text: "first")
    expect(page).not_to have_css("td", text: "third")
  end

  it "supports boolean filters" do
    %i[first second third].map do |n|
      create(:banner, name: n, active: n != :third)
    end

    visit "/admin/banners"

    find("main input[type=search]").click
    click_on("Active")
    click_on("Yes")

    expect(page).to have_current_path("/admin/posts?active=1")
    expect(page).to have_css("td", text: "first")
    expect(page).not_to have_css("td", text: "third")
  end

  it "clears filters" do
    visit "/admin/posts?search=#{query}"

    expect(page).to have_css("input[type=search][value=#{query}")
    expect(page).not_to have_css("td", text: "third")

    fill_in "Search", with: ""

    expect(page).to have_current_path("/admin/posts")
    expect(page).to have_css("td", text: "third")
  end

  context "when there are no results" do
    it "shows a placeholder message" do
      visit "/admin/posts?search=xxxxxx"

      expect(page).to have_css("caption", text: "No posts found.")
    end
  end

  context "when the content changes" do
    it "retains focus" do
      visit "/admin/posts"

      find("main input[type=search]").click
      expect(page).to have_css("main input[type=search]:focus")

      fill_in "Search", with: query

      expect(page).to have_current_path("/admin/posts?search=#{query}")
      expect(page).to have_css("main input[type=search]:focus")
    end
  end

  context "when paginating" do
    it "retains filter" do
      create_list(:post, 25, name: "first", title: "First")

      visit "/admin/posts?search=#{query}"

      click_on "Next"

      expect(page).to have_current_path("/admin/posts?search=#{query}&page=2")
      expect(page).to have_css("input[type=search][value=#{query}")
    end
  end

  context "when sorting" do
    it "retains filter" do
      visit "/admin/posts?search=#{query}"

      click_on "Title"

      expect(page).to have_current_path("/admin/posts?search=#{query}&sort=title+asc")
      expect(page).to have_css("input[type=search][value=#{query}]")
    end
  end

  context "with history navigation" do
    it "restores search state" do
      visit "/admin/posts"

      fill_in "Search", with: query

      expect(page).to have_current_path("/admin/posts?search=#{query}")

      click_on "Dashboard" # leave the page with turbo

      expect(page).to have_selector("h1", text: "Dashboard")

      page.go_back

      expect(page).to have_current_path("/admin/posts?search=#{query}")
      expect(page).to have_css("input[type=search][value=#{query}]")
    end
  end
end
