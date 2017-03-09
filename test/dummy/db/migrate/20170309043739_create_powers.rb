class CreatePowers < ActiveRecord::Migration
  def change
    create_table :powers do |t|
      t.string :title
      # Friendly ID
      t.string  :slug
      t.timestamps
    end
    add_index :powers, :slug, :unique => true
  end
end
