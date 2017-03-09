class AddPopularityToSuperHeros < ActiveRecord::Migration
  def change
    add_column :super_heros, :popularity, :integer
  end
end
