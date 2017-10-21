# This migration comes from koi (originally 20120605013044)
class AddSettingPrefixToNavItem < ActiveRecord::Migration[4.2]
  def change
    add_column :nav_items, :setting_prefix, :string
  end
end
