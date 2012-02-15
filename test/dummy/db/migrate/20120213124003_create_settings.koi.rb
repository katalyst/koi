# This migration comes from koi (originally 20120105070854)
class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string   :url
      t.string   :meta_title
      t.text     :meta_description
      t.integer  :set_id
      t.string   :set_type

      t.timestamps
    end

    add_index :settings, :url
    add_index :settings, :set_id
    add_index :settings, :set_type
  end
end
