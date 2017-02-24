class AddLastLocationSeenToSuperHero < ActiveRecord::Migration
  def change
    add_column :super_heros, :last_location_seen, :string
  end
end
