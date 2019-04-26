class AddTypeToSuperHero < ActiveRecord::Migration[4.2]
  def change
    add_column :super_heros, :type, :string
  end
end
