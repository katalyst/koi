# This migration comes from koi (originally 20111228035029)
class CreateNavItems < ActiveRecord::Migration
  def change
    create_table :nav_items do |t|
      t.string   :type
      t.string   :title
      t.string   :url
      t.string   :admin_url
      t.string   :key
      t.boolean  :is_hidden
      t.integer  :alias_id
      t.integer  :parent_id
      t.integer  :lft
      t.integer  :rgt
      t.text     :if
      t.text     :unless
      t.text     :method
      t.text     :highlights_on
      t.text     :content_block
      t.integer  :navigable_id
      t.string   :navigable_type

      t.timestamps
    end

    add_index :nav_items, :url
    add_index :nav_items, :navigable_id
    add_index :nav_items, :navigable_type
  end
end
