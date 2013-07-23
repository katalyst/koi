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
  'Option 1' => 1,
  'Option 2' => 2,
  'Option 3' => 3
}

Koi::Settings.collection = {
  title:       { label: "Title",       value: "title", field_type: 'text' },
  description: { label: "Description", value: "title", field_type: 'rich_text' },
  category:    { label: "Category",    field_type: "select", data_source: Proc.new { Category.all } },
  options:     { label: "Options",     field_type: "select", data_source: Proc.new { SettingOptions }},
  rad_options: { label: "RadOptions",  field_type: "radio",  data_source: Proc.new { SettingOptions }},
  chk_options: { label: "ChkOptions",  field_type: "check_boxes", data_source: Proc.new { SettingOptions }},
  image:       { label: "Image",       field_type: "image" },
  document:    { label: "Document",    field_type: "file" }
}

Koi::Settings.resource = {
  string:    { label: "String",   field_type: "string", value: 'Test' },
  title:     { label: "Title",    field_type: "text",   value: 'Test' },
  rich_text: { label: "RichText", field_type: "rich_text" },
  image:     { label: "Image",    field_type: "image" },
  boolean:   { label: "Boolean",  field_type: "boolean", is_required: true },
  options:   { label: "Options",  field_type: "check_boxes", data_source: Proc.new { SettingOptions }, value: 2 },
  document:  { label: "Document", field_type: "file" }
}

Koi::Asset::Image.sizes = [
  { width: '200', title: '200 pixels wide' },
  { width: '400', title: '400 pixels wide' },
  { width: '600', title: '600 pixels wide' }
]
