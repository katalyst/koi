class CreatePageContents < ActiveRecord::Migration
  def change
    create_table :page_contents do |t|
      t.string :content_type
      t.string :string
      t.text :text
      t.string :file_uid
      t.string :file_name
      t.integer :file_id
      t.string :file_ids
      t.integer :module_limit
      t.string :module_ordered_by
      t.boolean :module_paginated
      t.string :module_category
      t.boolean :active
      t.integer :ordinal
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :page_contents, :slug, :unique => true
  end
end

