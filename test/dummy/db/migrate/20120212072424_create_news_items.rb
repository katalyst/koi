class CreateNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.string :title
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :news_items, :slug, :unique => true
  end
end

