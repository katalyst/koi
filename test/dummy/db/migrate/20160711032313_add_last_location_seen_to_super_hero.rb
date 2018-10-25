class AddLastLocationSeenToSuperHero < ActiveRecord::Migration[4.2]
  def change
    add_column :super_heros, :last_location_seen, :string
  end
end
