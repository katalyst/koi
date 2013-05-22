# This migration comes from koi (originally 20130509235316)
class AddUrlRewriter < ActiveRecord::Migration
  def change
    create_table :url_rewrites do |t|
      t.text    :from
      t.text    :to
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
