# This migration comes from koi (originally 20120503062634)
class AddIsMobileToNavItem < ActiveRecord::Migration
  def change
    add_column :nav_items, :is_mobile, :boolean, default: false
  end
end
