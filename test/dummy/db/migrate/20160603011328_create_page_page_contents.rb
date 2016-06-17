class CreatePagePageContents < ActiveRecord::Migration
  def change
    create_table :page_page_contents do |t|
      t.integer :page_id
      t.integer :page_content_id
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :page_page_contents, :slug, :unique => true
  end
end

