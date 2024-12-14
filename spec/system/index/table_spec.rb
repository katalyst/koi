# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/table" do
  let(:admin) { create(:admin) }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"
  end

  it "renders a table" do
    posts = create_list(:post, 3)

    visit "/admin/posts"

    expect(page).to have_css("td", text: posts.first.title)
  end

  context "when there are no results" do
    it "shows a placeholder message" do
      visit "/admin/posts"

      expect(page).to have_css("caption", text: "No posts found.")
    end
  end
end
