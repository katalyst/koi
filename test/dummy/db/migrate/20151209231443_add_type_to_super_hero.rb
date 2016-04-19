class AddTypeToSuperHero < ActiveRecord::Migration
  def change
    add_column :super_heros, :type, :string
  end
end
