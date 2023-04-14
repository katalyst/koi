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

ActiveRecord::Schema[7.0].define(version: 2023_04_12_023411) do
  create_table "admin_credentials", force: :cascade do |t|
    t.string "external_id"
    t.integer "admin_id", null: false
    t.string "public_key"
    t.string "nickname"
    t.bigint "sign_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_credentials_on_admin_id"
    t.index ["external_id"], name: "index_admin_credentials_on_external_id", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "password_digest", default: "", null: false
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
    t.string "webauthn_id"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
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

  create_table "url_rewrites", force: :cascade do |t|
    t.text "from"
    t.text "to"
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  add_foreign_key "admin_credentials", "admins"
  add_foreign_key "katalyst_navigation_items", "katalyst_navigation_menus", column: "menu_id"
  add_foreign_key "katalyst_navigation_menu_versions", "katalyst_navigation_menus", column: "parent_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "draft_version_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "published_version_id"
end
