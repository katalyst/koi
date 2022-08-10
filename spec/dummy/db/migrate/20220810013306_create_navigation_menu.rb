class CreateNavigationMenu < ActiveRecord::Migration[7.0]
  def change
    create_table :navigation_menus do |t|
      t.string :title
      t.string :slug, index: true

      t.references :current_version
      t.references :latest_version

      t.timestamps
    end

    create_table :navigation_menu_versions do |t|
      t.belongs_to :parent, foreign_key: { to_table: :navigation_menus }, null: false
      t.json :items

      t.timestamps
    end

    add_foreign_key :navigation_menus, :navigation_menu_versions, column: :current_version_id
    add_foreign_key :navigation_menus, :navigation_menu_versions, column: :latest_version_id

    create_table :navigation_links do |t|
      t.belongs_to :navigation_menu, foreign_key: true, null: false

      t.string :title, null: false
      t.string :url, null: false
      t.string :css
      t.boolean :visible, default: true
      t.boolean :new_tab
      t.string :aria_label

      t.timestamps
    end
  end
end
