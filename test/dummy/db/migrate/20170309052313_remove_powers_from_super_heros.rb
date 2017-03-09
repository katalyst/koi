class RemovePowersFromSuperHeros < ActiveRecord::Migration
  def change
    remove_column :super_heros, :powers, :string
  end
end
