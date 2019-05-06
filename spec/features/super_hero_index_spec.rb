require "rails_helper"

describe "super hero index" do
  include_context "admin_signed_in"

  it "displays table of super heros" do
    create(:iron_man)
    create(:captain_america)
    visit admin_super_heros_path
    expect(page).to have_text("Iron Man")
    expect(page).to have_text("Captain America")
    expect(page).to have_text("2 items")
  end

  it "allows super heroes to be edited" do
    iron_man = create(:iron_man)
    visit admin_super_heros_path
    click_on "Edit"
    expect(page.current_path).to eql(edit_admin_super_hero_path(iron_man))
  end

  it "has link to super hero details page" do
    iron_man = create(:iron_man)
    visit admin_super_heros_path
    click_on "Show"
    expect(page.current_path).to eql(admin_super_hero_path(iron_man))
  end

  it "allows super heroes to be created" do
    visit admin_super_heros_path
    click_on "Add Super hero"
    expect(page.current_path).to eql(new_admin_super_hero_path)
  end

  it "allows super heroes to be searched" do
    create(:iron_man)
    create(:captain_america)
    visit admin_super_heros_path
    fill_in "Search", with: "Captain"
    click_on "Go"
    expect(page).to     have_text("Captain America")
    expect(page).to_not have_text("Iron Man")
    click_on "Reset"
    expect(page).to have_text("Iron Man")
  end

  it "allows super heroes to be downloaded as csv" do
    create(:iron_man)
    create(:captain_america)
    visit admin_super_heros_path
    click_on "Download CSV"

    csv = CSV.parse(page.body, headers: true)
    first_row_name = csv.first["Name"]

    expect(first_row_name).to eql("Iron Man")
  end
end
