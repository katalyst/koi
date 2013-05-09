# This migration comes from koi (originally 20120821110926)
class AddSlugToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :slug, :string
  end
end
