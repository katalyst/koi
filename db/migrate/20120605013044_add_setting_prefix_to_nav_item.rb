class AddSettingPrefixToNavItem < ActiveRecord::Migration[5.0]
  def change
    add_column :nav_items, :setting_prefix, :string
  end
end
