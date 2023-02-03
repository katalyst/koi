# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.boolean :show_title, default: false, null: false
      t.string :slug, null: false, unique: true

      t.timestamps
    end

    create_table :article_versions do |t|
      t.references :parent, foreign_key: { to_table: :articles }, null: false
      t.json :nodes

      t.timestamps
    end

    change_table :articles do |t|
      t.references :published_version, foreign_key: { to_table: :article_versions }
      t.references :draft_version, foreign_key: { to_table: :article_versions }
    end
  end
end
