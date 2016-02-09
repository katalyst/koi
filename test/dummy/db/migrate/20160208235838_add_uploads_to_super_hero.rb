class AddUploadsToSuperHero < ActiveRecord::Migration
  def change
    add_column :super_heros, :image_upload_id, :integer
    add_column :super_heros, :image_upload_crop, :string
    add_column :super_heros, :document_upload_id, :integer
    add_column :super_heros, :document_upload_crop, :string
  end
end
