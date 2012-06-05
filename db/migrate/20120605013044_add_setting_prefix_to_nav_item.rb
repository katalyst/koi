class AddSettingPrefixToNavItem < ActiveRecord::Migration
  def change
    add_column :nav_items, :setting_prefix, :string
  end
end
