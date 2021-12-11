class AddLinkToChildToNavItem < ActiveRecord::Migration[4.2]
  def change
    add_column :nav_items, :link_to_first_child, :boolean
  end
end
