# frozen_string_literal: true

class RemoveNavItem < ActiveRecord::Migration[7.0]
  def change
    drop_table :nav_items do |t|
      t.string   :type
      t.string   :title
      t.string   :url, index: true
      t.string   :admin_url
      t.string   :key
      t.boolean  :is_hidden
      t.integer  :alias_id
      t.integer  :parent_id
      t.integer  :lft
      t.integer  :rgt
      t.text     :method
      t.integer  :navigable_id, index: true
      t.string   :navigable_type, index: true
      t.boolean  :is_mobile, default: false
      t.string :setting_prefix
      t.boolean :link_to_first_child, default: false, null: false
      t.integer  :navigable_id
      t.string   :navigable_type
      t.index

      t.timestamps
    end
  end
end
