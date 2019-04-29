require "rails_helper"

describe "super hero form" do
  include_context "admin_signed_in"

  it "allows creation of a super hero" do
    visit new_admin_super_hero_path
    fill_in "Name", with: "Thor"
    fill_in "Description", with: "He's got a big hammer"
    fill_in "Published at", with: "17 Apr 2019"
    select "Male", from: "Gender"
    check "Is alive"
    check "WEATHER CONTROL"
    check "SUPER STRENGTH"
    first(:button, "Save").click
    expect(page).to have_text("Super hero was successfully created.")
    expect(page).to have_text("Thor")
  end
end
