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

    it "allows products to be deleted inside a category" do
      category = create(:category, name: "Outdoors")
      product  = create(:product, category: category, name: "Frisbee")
      visit(edit_admin_category_path(category))
      expect(page).to have_text("Frisbee")
      within ".inline-nested-form" do
        click_on "Delete"
      end
      accept_alert
      click_on "Save"
      expect(Product.count).to be_zero
    end

    it "allows products to be edited inside a category" do
      category = create(:category, name: "Outdoors")
      product  = create(:product, category: category, name: "Frisbee")
      visit(edit_admin_category_path(category))
      expect(page).to have_text("Frisbee")
      within ".inline-nested-form" do
        find("[data-inline-nested-field-toggle]").click
        expect(page).to have_css('.nested-inline-fields')
        fill_in "Name", with: "Ultimate Frisbee"
      end
      click_on "Save"
      expect(Product.first.name).to eql("Ultimate Frisbee")
    end
end
