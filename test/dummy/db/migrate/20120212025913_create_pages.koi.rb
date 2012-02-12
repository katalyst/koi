# This migration comes from koi (originally 20111230064607)
class CreatePages < ActiveRecord::Migration
  def change
    create_table :koi_pages do |t|
      t.string   :title
      t.text     :description
      t.string   :slug

      t.timestamps
    end

    add_index :koi_pages, :slug, :unique => true
  end
end
