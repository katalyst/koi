# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/pagination" do
  let(:admin) { create(:admin) }
  let(:posts) { Post.order(name: :asc) }

  before do
    create_list(:post, 25) # rubocop:disable FactoryBot/ExcessiveCreateList

    visit "/admin"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_on "Log in"
  end

  context "when there are more than 20 results" do
    it "supports pagination" do
      visit "/admin/posts"

      expect(page).to have_css("td", text: posts.first.title)

      click_on "Next"

      expect(page).to have_css("td", text: posts.last.title)
    end
  end

  context "when a new filter is applied" do
    let(:search) { posts.first.title.split(/\W+/).first }

    it "clears pagination" do
      visit "/admin/posts?page=2"

      fill_in "Search", with: search

      expect(page).to have_current_path("/admin/posts?search=#{search}")
    end
  end

  context "when a new sort is applied" do
    it "clears pagination" do
      visit "/admin/posts?page=2"

      click_on "Title"

      expect(page).to have_current_path("/admin/posts?sort=title+asc")
    end
  end
end
