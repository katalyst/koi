# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/filtering" do
  let(:admin) { create(:admin) }
  let(:query) { "first" }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_button "Log in"

    %i[first second third].map do |n|
      create(:post, name: n, title: n.to_s.titleize)
    end
  end

  it "applies filters" do
    visit "/admin/posts"

    fill_in "Search", with: query

    expect(page).to have_current_path("/admin/posts?search=#{query}")
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
    xit "shows a placeholder message" do
      visit "/admin/posts?search=xxxxxx"

      expect(page).to have_css("caption", text: "No posts found")
    end
  end

  context "when the content changes" do
    xit "retains focus" do
      visit "/admin/posts"

      fill_in "Search", with: query

      expect(page).to have_current_path("/admin/posts?search=#{query}")
      expect(page).to have_css("input[type=search]:focus")
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
      expect(page).to have_css("input[type=search][value=#{query}")
    end
  end
end