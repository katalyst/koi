class AddManagedAssetsToSuperHero < ActiveRecord::Migration[5.1]
  def change
    add_column :super_heros, :managed_image_asset_id, :integer
    add_column :super_heros, :managed_document_asset_id, :integer
  end
end
