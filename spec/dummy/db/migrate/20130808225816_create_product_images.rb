# frozen_string_literal: true

class CreateProductImages < ActiveRecord::Migration[4.2]
  def change
    create_table :product_images do |t|
      t.integer :product_id
      t.string  :product_type
      t.string  :title
      t.string  :description
      t.string  :image_uid
      t.integer :ordinal
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :product_images, :slug, unique: true
  end
end
