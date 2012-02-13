# This migration comes from koi (originally 20120108235235)
class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string   :data_uid
      t.string   :data_name
      t.string   :type
      t.integer  :attribute_ordinal
      t.string   :attribute_name
      t.integer  :attributable_id
      t.string   :attributable_type

      t.timestamps
    end
  end
end
