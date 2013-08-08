class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.integer :product_id
      t.string :image_uid
      t.integer :ordinal
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :product_images, :slug, :unique => true
  end
end

