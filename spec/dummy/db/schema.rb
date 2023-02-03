# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_03_040543) do
  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "assets", force: :cascade do |t|
    t.string "data_uid"
    t.string "data_name"
    t.string "type"
    t.integer "attribute_ordinal"
    t.string "attribute_name"
    t.integer "attributable_id"
    t.string "attributable_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 40
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "katalyst_content_items", force: :cascade do |t|
    t.string "type"
    t.string "container_type"
    t.integer "container_id"
    t.string "heading", null: false
    t.boolean "show_heading", default: true, null: false
    t.string "background", null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "caption"
    t.index ["container_type", "container_id"], name: "index_katalyst_content_items_on_container"
  end

  create_table "katalyst_navigation_items", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.string "type"
    t.string "title"
    t.string "url"
    t.string "http_method"
    t.string "target"
    t.boolean "visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_katalyst_navigation_items_on_menu_id"
  end

  create_table "katalyst_navigation_menu_versions", force: :cascade do |t|
    t.integer "parent_id", null: false
    t.json "nodes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_katalyst_navigation_menu_versions_on_parent_id"
  end

  create_table "katalyst_navigation_menus", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.integer "published_version_id"
    t.integer "draft_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "depth"
    t.index ["draft_version_id"], name: "index_katalyst_navigation_menus_on_draft_version_id"
    t.index ["published_version_id"], name: "index_katalyst_navigation_menus_on_published_version_id"
    t.index ["slug"], name: "index_katalyst_navigation_menus_on_slug"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "url_rewrites", force: :cascade do |t|
    t.text "from"
    t.text "to"
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  add_foreign_key "katalyst_navigation_items", "katalyst_navigation_menus", column: "menu_id"
  add_foreign_key "katalyst_navigation_menu_versions", "katalyst_navigation_menus", column: "parent_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "draft_version_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "published_version_id"
end
