# frozen_string_literal: true

# This migration comes from katalyst_navigation (originally 20220826034507)
class CreateKatalystNavigationItems < ActiveRecord::Migration[7.0]
  def change
    create_table :katalyst_navigation_items do |t|
      t.belongs_to :menu, foreign_key: { to_table: :katalyst_navigation_menus }, null: false

      t.string :type
      t.string :title
      t.string :url
      t.string :http_method
      t.string :target
      t.boolean :visible, default: true

      t.timestamps
    end
  end
end
