class AddLinkToChildToNavItem < ActiveRecord::Migration[5.0]
  def change
    add_column :nav_items, :link_to_first_child, :boolean
  end
end
