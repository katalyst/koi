# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/ordinal" do
  let(:admin) { create(:admin) }

  before do
    visit "/admin"

    fill_in "Email", with: admin.email
    click_on "Next"

    fill_in "Password", with: admin.password
    click_on "Next"

    fill_in "Token", with: admin.otp.now
    click_on "Next"

    %i[first second third].each_with_index do |n, i|
      create(:banner, name: n, ordinal: i)
    end
  end

  it "supports mouse re-ordering" do
    visit "/admin/banners"

    within("tbody") do
      first = page.find("tr:first-child td.ordinal")
      last  = page.find("tr:last-child td.ordinal")
      first.drag_to(last, steps: 10)
    end

    expect(page).to have_css("tr:last-child td", text: "first")

    expect(Banner.all).to contain_exactly(
      have_attributes(name: "second", ordinal: 0),
      have_attributes(name: "third", ordinal: 1),
      have_attributes(name: "first", ordinal: 2),
    )
  end

  it "supports keyboard re-ordering", pending: "unimplemented" do
    visit "/admin/banners"

    find("table").send_keys("ff", "k", [:shift, "k"])

    expect(page).to have_css("tr:last-child td", text: "second")
  end
end
