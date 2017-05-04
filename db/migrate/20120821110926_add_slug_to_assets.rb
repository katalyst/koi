class AddSlugToAssets < ActiveRecord::Migration[5.0]
  def change
    add_column :assets, :slug, :string
  end
end
