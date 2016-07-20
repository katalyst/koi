class CreateComposablePages < ActiveRecord::Migration
  def change

    create_table :composable_pages do |t|
      t.string   :title
      t.text     :description
      t.string   :slug
      t.timestamps
    end
    add_index :composable_pages, :slug, :unique => true

    create_table :composable_contents do |t|
      t.string :content_type
      t.string :string
      t.text :text
      t.text :rich_text
      t.string :file_uid
      t.string :file_name
      t.integer :file_id
      t.string :file_ids
      t.string :partial
      t.string :composable_type
      t.integer :composable_id
      t.boolean :active
      t.integer :ordinal
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :composable_contents, :slug, :unique => true

  end
end

