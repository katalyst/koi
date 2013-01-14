class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :ordinal
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :categories, :slug, :unique => true
  end
end

