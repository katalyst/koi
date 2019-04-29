require "rails_helper"

describe "category form", js: true do
  include_context "admin_signed_in"

  it "allows creating of products inside a category" do
    visit(admin_categories_path)
    click_on "Add Category"
    fill_in "Name", with: "Outdoors"
    click_on "Add products to this category"
    within ".nested-inline-fields" do
      fill_in "Name", with: "Frisbee"
      fill_in "Colour", with: "#9c5153"
    end
    click_on "Save"
    expect(Product.count).to eql(1)
  end

end
