# This migration comes from koi (originally 20120303010729)
class CreateExits < ActiveRecord::Migration
  def change
    create_table :exits do |t|
      t.text :page_path
      t.integer :pageviews
      t.integer :unique_pageviews
      t.integer :exits

      t.timestamps
    end
  end
end
