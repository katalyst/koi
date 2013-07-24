# Koi::Asset::Document.extensions = [:pdf, :doc]

Koi::Menu.items = {
  "Super Heros"  => "/admin/super_heros",
  "Admins"       => "/admin/site_users",
  "News"         => "/admin/news_items",
  "Categories"   => "/admin/categories",
  "URL History"  => "/admin/friendly_id_slugs",
  "URL Rewriter" => "/admin/url_rewrites"
}

# Look at FieldTypes in app/models/settings.rb for supported types

SettingOptions = {
  'Option 1' => '1',
  'Option 2' => '2',
  'Option 3' => '3'
}

Koi::Settings.collection = {
  options:     { label: "Options",          group: "Group 2", field_type: "select", data_source: Proc.new { SettingOptions }},
  rad_options: { label: "RadOptions",       group: "Group 2", field_type: "radio",  data_source: Proc.new { SettingOptions }},
  title:       { label: "Title",            group: "SEO", field_type: 'string' },
  description: { label: "Meta Description", group: "SEO", field_type: 'text' },
  keywords:    { label: "Meta Keywords",    group: "SEO", field_type: 'text' },
  chk_options: { label: "ChkOptions",       group: "Group 3", field_type: "check_boxes", data_source: Proc.new { SettingOptions }},
  image:       { label: "Image",            field_type: "image" },
  document:    { label: "Document",         field_type: "file" }
}

Koi::Settings.resource = {
  title:       { label: "Title",            group: "SEO", field_type: 'string' },
  description: { label: "Meta Description", group: "SEO", field_type: 'text' },
  keywords:    { label: "Meta Keywords",    group: "SEO", field_type: 'text' },
  rich_text:   { label: "RichText",         group: "Group 2", field_type: "rich_text" },
  image:       { label: "Image",            group: "Group 2", field_type: "image" },
  boolean:     { label: "Boolean",          field_type: "boolean", is_required: true },
  options:     { label: "Options",          field_type: "check_boxes", data_source: Proc.new { SettingOptions }, value: 2 },
  document:    { label: "Document",         field_type: "file" }
}

Koi::Asset::Image.sizes = [
  { width: '200', title: '200 pixels wide' },
  { width: '400', title: '400 pixels wide' },
  { width: '600', title: '600 pixels wide' }
]
