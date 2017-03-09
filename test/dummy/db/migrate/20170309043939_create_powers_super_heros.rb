class CreatePowersSuperHeros < ActiveRecord::Migration
  def change
    create_table :powers_super_heros, id: false do |t|
      t.integer :power_id
      t.integer :super_hero_id
    end
  end
end
