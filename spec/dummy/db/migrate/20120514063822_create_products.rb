# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.integer :category_id
      t.string :name
      t.text :description
      # Friendly ID
      t.string :slug
      t.timestamps
    end
    add_index :products, :slug, unique: true
  end
end
