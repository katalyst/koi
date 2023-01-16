# frozen_string_literal: true

class DropLegacyPages < ActiveRecord::Migration[7.0]
  def change
    drop_table "legacy_pages", force: :cascade do |t|
      t.string "title"
      t.text "description"
      t.string "slug"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index ["slug"], name: "index_legacy_pages_on_slug", unique: true
    end
  end
end
