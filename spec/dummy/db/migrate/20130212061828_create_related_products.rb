class CreateRelatedProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :related_products, id: false do |t|
      t.integer :product_a_id, null: false
      t.integer :product_b_id, null: false

      t.timestamps
    end
  end
end
