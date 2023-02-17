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

ActiveRecord::Schema[7.0].define(version: 2023_03_03_053940) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "article_versions", force: :cascade do |t|
    t.integer "parent_id", null: false
    t.json "nodes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_article_versions_on_parent_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "show_title", default: false, null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "published_version_id"
    t.integer "draft_version_id"
    t.string "short_description"
    t.index ["draft_version_id"], name: "index_articles_on_draft_version_id"
    t.index ["published_version_id"], name: "index_articles_on_published_version_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "article_versions", "articles", column: "parent_id"
  add_foreign_key "articles", "article_versions", column: "draft_version_id"
  add_foreign_key "articles", "article_versions", column: "published_version_id"
  add_foreign_key "katalyst_navigation_items", "katalyst_navigation_menus", column: "menu_id"
  add_foreign_key "katalyst_navigation_menu_versions", "katalyst_navigation_menus", column: "parent_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "draft_version_id"
  add_foreign_key "katalyst_navigation_menus", "katalyst_navigation_menu_versions", column: "published_version_id"
end
