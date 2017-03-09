class AddBirthdateToSuperHero < ActiveRecord::Migration
  def change
    add_column :super_heros, :birthdate, :date
  end
end
