# frozen_string_literal: true

# This migration comes from katalyst_navigation (originally 20220826034507)
class CreateKatalystNavigationLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :katalyst_navigation_links do |t|
      t.belongs_to :menu, foreign_key: { to_table: :katalyst_navigation_menus }, null: false

      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
