# Koi::Asset::Document.extensions = [:pdf, :doc]

Koi::Menu.items = {
  "Super Heros"  => "/admin/super_heros",
  "News"         => "/admin/news_items",
  "Categories"   => "/admin/categories",
  "URL History"  => "/admin/friendly_id_slugs",
  "URL Rewriter" => "/admin/url_rewrites"
}

Koi::Menu.advanced = {
  "Admins"       => "/admin/site_users",
  "URL History"  => "/admin/friendly_id_slugs",
  "URL Rewriter" => "/admin/url_rewrites"
}

Koi::Asset::Image.sizes = [
  { width: '200', title: '200 pixels wide' },
  { width: '400', title: '400 pixels wide' },
  { width: '600', title: '600 pixels wide' }
]

# Look at FieldTypes in app/models/settings.rb for supported types

SettingOptions = {
  'Option 1' => '1',
  'Option 2' => '2',
  'Option 3' => '3'
}

settings = {
  title:       { label: "Title",            group: "SEO", field_type: 'string' },
  description: { label: "Meta Description", group: "SEO", field_type: 'text' },
  keywords:    { label: "Meta Keywords",    group: "SEO", field_type: 'text' },

  input:       { label: "Input",            field_type: 'string' },
  text:        { label: "Text",             field_type: 'text' },
  rich_text:   { label: "Rich Text",        field_type: "rich_text" },
  select:      { label: "Select",           field_type: "select", data_source: Proc.new { SettingOptions } },
  radio:       { label: "Radio Buttons",    field_type: "radio", data_source: Proc.new { SettingOptions } },
  checkboxes:  { label: "Check Boxes",      field_type: "check_boxes", data_source: Proc.new { SettingOptions } },
  boolean:     { label: "Boolean",          field_type: "boolean", is_required: true },
  image:       { label: "Image",            field_type: "image" },
  document:    { label: "Document",         field_type: "file" },

  news_tags:   { label: "News Tags", group: 'Tags', field_type: 'tags', data_source: Proc.new { ActsAsTaggableOn::Tag.all.map(&:name) } },
  faq_tags:    { label: "FAQ Tags",  group: 'Tags', field_type: 'tags' }
}

resource_settings = settings.merge({
  resource_tags: { label: "Resource Tags",  group: 'Tags', field_type: 'tags' }
})

Koi::Settings.collection = settings
Koi::Settings.resource = resource_settings

# Caching enabled by default
Koi::Caching.enabled = true

# Expiry in 60.minutes by default
Koi::Caching.expires_in = 5.minutes
