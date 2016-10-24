class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string :name
      t.float :engine_size
      t.text :description
      t.boolean :classic

      t.timestamps null: false
    end
  end
end
