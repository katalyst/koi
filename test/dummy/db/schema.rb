# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130808225816) do

  create_table "admins", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "role"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "assets", :force => true do |t|
    t.string   "data_uid"
    t.string   "data_name"
    t.string   "type"
    t.integer  "attribute_ordinal"
    t.string   "attribute_name"
    t.integer  "attributable_id"
    t.string   "attributable_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "slug"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "ordinal"
    t.string   "slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "categories", ["slug"], :name => "index_categories_on_slug", :unique => true

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "nav_items", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.string   "url"
    t.string   "admin_url"
    t.string   "key"
    t.boolean  "is_hidden"
    t.integer  "alias_id"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.text     "if"
    t.text     "unless"
    t.text     "method"
    t.text     "highlights_on"
    t.text     "content_block"
    t.integer  "navigable_id"
    t.string   "navigable_type"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "is_mobile",      :default => false
    t.string   "setting_prefix"
  end

  add_index "nav_items", ["navigable_id"], :name => "index_nav_items_on_navigable_id"
  add_index "nav_items", ["navigable_type"], :name => "index_nav_items_on_navigable_type"
  add_index "nav_items", ["url"], :name => "index_nav_items_on_url"

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "news_items", ["slug"], :name => "index_news_items_on_slug", :unique => true

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "slug"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "pages", ["slug"], :name => "index_pages_on_slug", :unique => true

  create_table "product_images", :force => true do |t|
    t.integer  "product_id"
    t.string   "product_type"
    t.string   "title"
    t.string   "description"
    t.string   "image_uid"
    t.integer  "ordinal"
    t.string   "slug"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "product_images", ["slug"], :name => "index_product_images_on_slug", :unique => true

  create_table "products", :force => true do |t|
    t.integer  "category_id"
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.text     "short_description"
    t.date     "publish_date"
    t.date     "launch_date"
    t.text     "genre"
    t.string   "banner_uid"
    t.string   "banner_name"
    t.string   "manual_uid"
    t.string   "manual_name"
    t.string   "size"
    t.text     "countries"
    t.string   "colour"
    t.boolean  "active",            :default => true
    t.integer  "ordinal"
  end

  add_index "products", ["slug"], :name => "index_products_on_slug", :unique => true

  create_table "related_products", :id => false, :force => true do |t|
    t.integer  "product_a_id", :null => false
    t.integer  "product_b_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.integer  "visits"
    t.integer  "unique_pageviews"
    t.integer  "pageviews"
    t.float    "pageviews_per_visit"
    t.float    "avg_time_on_site"
    t.float    "visit_bounce_rate"
    t.integer  "new_visits"
    t.integer  "organic_searches"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "super_heros", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "published_at"
    t.string   "gender"
    t.boolean  "is_alive",     :default => true
    t.string   "url"
    t.string   "telephone"
    t.string   "image_uid"
    t.string   "image_name"
    t.string   "file_uid"
    t.string   "file_name"
    t.integer  "value"
    t.string   "powers"
    t.string   "slug"
    t.integer  "ordinal"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "super_heros", ["slug"], :name => "index_super_heros_on_slug", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "translations", :force => true do |t|
    t.string   "locale",           :default => "en"
    t.string   "label"
    t.string   "key"
    t.text     "value"
    t.text     "interpolations"
    t.string   "role"
    t.string   "field_type",       :default => "string"
    t.string   "hint"
    t.boolean  "is_proc",          :default => false
    t.boolean  "is_required",      :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "prefix"
    t.string   "file_uid"
    t.string   "file_name"
    t.text     "serialized_value"
    t.string   "group"
  end

  add_index "translations", ["locale", "prefix", "key"], :name => "index_translations_on_locale_and_prefix_and_key", :unique => true

  create_table "url_rewrites", :force => true do |t|
    t.text     "from"
    t.text     "to"
    t.boolean  "active",     :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
