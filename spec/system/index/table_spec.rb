# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/table" do
  let(:admin) { create(:admin) }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    fill_in "Password", with: admin.password
    click_button "Log in"
  end

  it "renders a table" do
    posts = create_list(:post, 3)

    visit "/admin/posts"

    expect(page).to have_css("td", text: posts.first.title)
  end

  context "when there are no results" do
    xit "shows a placeholder message" do
      visit "/admin/posts"

      expect(page).to have_css("caption", text: "No posts found")
    end
  end
end
