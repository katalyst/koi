class AddPowerlevelToSuperHeros < ActiveRecord::Migration
  def change
    add_column :super_heros, :power_level, :integer
  end
end
