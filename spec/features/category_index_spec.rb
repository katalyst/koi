require "rails_helper"

describe "category index" do
  include_context "admin_signed_in"

  it "respects the order of categories" do
    outdoors = create(:category, name: "Outdoors", ordinal: 1)
    indoors  = create(:category, name: "Indoors", ordinal: 2)
    visit(admin_categories_path)
    expect("Outdoors").to appear_before("Indoors")
    outdoors.update(ordinal: 2)
    indoors.update(ordinal: 1)
    visit(current_path)
    expect("Indoors").to appear_before("Outdoors")
  end

end
