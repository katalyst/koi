# frozen_string_literal: true

# This migration comes from katalyst_navigation (originally 20220826034057)
class CreateKatalystNavigationMenus < ActiveRecord::Migration[7.0]
  def change
    create_table :katalyst_navigation_menus do |t|
      t.string :title
      t.string :slug, index: true

      t.references :published_version
      t.references :draft_version

      t.timestamps
    end

    create_table :katalyst_navigation_menu_versions do |t|
      t.references :parent, foreign_key: { to_table: :katalyst_navigation_menus }, null: false
      t.json :nodes

      t.timestamps
    end

    add_foreign_key :katalyst_navigation_menus, :katalyst_navigation_menu_versions, column: :published_version_id
    add_foreign_key :katalyst_navigation_menus, :katalyst_navigation_menu_versions, column: :draft_version_id
  end
end
