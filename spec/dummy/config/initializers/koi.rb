# frozen_string_literal: true

# Koi::KoiAsset::Document.extensions = [:pdf, :doc]

Koi::Menu.items = {
  "Modules"  => {
    "News"       => "/admin/news_items",
    "Categories" => "/admin/categories",
    "Heroes"     => {
      "Super Heros" => "/admin/super_heros",
      "Kid Heros"   => "/admin/kid_heros",
    },
  },
  "Advanced" => {
    "Admins"       => "/admin/site_users",
    "URL History"  => "/admin/friendly_id_slugs",
    "URL Rewriter" => "/admin/url_rewrites",
  },
}

Koi::PriorityMenu.items = [
  {
    label:     "View Website",
    url:       "/",
    icon:      "planet_filled",
    icon_opts: { fill: "#2ECC71" },
  },
  {
    label: "Super Heros",
    url:   "/admin/super_heros",
  },
]

Koi::KoiAsset::Image.sizes = [
  { width: "200", title: "200 pixels wide" },
  { width: "400", title: "400 pixels wide" },
  { width: "600", title: "600 pixels wide" },
]

# Look at FieldTypes in app/models/settings.rb for supported types

SETTING_OPTIONS = {
  "Option 1" => "1",
  "Option 2" => "2",
  "Option 3" => "3",
}.freeze

settings = {
  title:       { label: "Title", group: "SEO", field_type: "string" },
  description: { label: "Meta Description", group: "SEO", field_type: "text" },
  keywords:    { label: "Meta Keywords", group: "SEO", field_type: "text" },

  input:       { label: "Input", field_type: "string" },
  text:        { label: "Text", field_type: "text" },
  rich_text:   { label: "Rich Text", field_type: "rich_text" },
  select:      { label: "Select", field_type: "select", data_source: proc { SETTING_OPTIONS } },
  radio:       { label: "Radio Buttons", field_type: "radio", data_source: proc { SETTING_OPTIONS } },
  checkboxes:  { label: "Check Boxes", field_type: "check_boxes", data_source: proc { SETTING_OPTIONS } },
  boolean:     { label: "Boolean", field_type: "boolean", is_required: true },
  image:       { label: "Image", field_type: "image" },
  document:    { label: "Document", field_type: "file" },

  news_tags:   { label: "News Tags", group: "Tags", field_type: "tags", data_source: proc do
                                                                                       ActsAsTaggableOn::Tag.all.map(&:name)
                                                                                     end },
  faq_tags:    { label: "FAQ Tags", group: "Tags", field_type: "tags" },
}

resource_settings = settings.merge({
                                     resource_tags: { label: "Resource Tags", group: "Tags", field_type: "tags" },
                                   })

Koi::Settings.collection = settings
Koi::Settings.resource = resource_settings
Koi::Settings.skip_on_create = [:news_item]

# Caching enabled by default
Koi::Caching.enabled = true

# Expiry in 60.minutes by default
Koi::Caching.expires_in = 5.minutes
