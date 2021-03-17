class UpdateLinkToFirstChildOnNavItems < ActiveRecord::Migration
  def change
    # set folder nav items link_to_first_child to true if undefined
    FolderNavItem.where(link_to_first_child: nil).update_all(link_to_first_child: true)
    # update all other items set to false where null (required by mysql)
    NavItem.where(link_to_first_child: nil).update_all(link_to_first_child: false)

    # update link_to_first_child, non null default false
    change_column :nav_items, :link_to_first_child, :boolean, null: false, default: false
  end
end
