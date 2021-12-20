# frozen_string_literal: true

class AddUploadsToSuperHero < ActiveRecord::Migration[4.2]
  def change
    add_column :super_heros, :image_upload_id, :integer
    add_column :super_heros, :image_upload_crop, :string
    add_column :super_heros, :document_upload_id, :integer
    add_column :super_heros, :document_upload_crop, :string
  end
end
