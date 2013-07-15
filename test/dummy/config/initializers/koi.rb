# Koi::Asset::Document.extensions = [:pdf, :doc]

Koi::Menu.items = {
  "Super Heros"  => "/admin/super_heros",
  "Admins"       => "/admin/site_users",
  "News"         => "/admin/news_items",
  "Categories"   => "/admin/categories",
  "URL History"  => "/admin/friendly_id_slugs",
  "URL Rewriter" => "/admin/url_rewrites"
}


# Look at FieldTypes in app/models/translation.rb for supported types

Koi::Settings.collection = {
  title:       { label: "Title",       value: "title", field_type: 'text' },
  description: { label: "Description", value: "title", field_type: 'rich_text' }
}

Koi::Settings.resource = {
  string:    { label: "Banners",  field_type: "string", value: 'Test' },
  title:     { label: "Title",    field_type: "text",   value: 'Test' },
  rich_text: { label: "RichText", field_type: "rich_text" },
  images:    { label: "Images",   field_type: "images" },
  boolean:   { label: "Boolean",  field_type: "boolean" }
}

Koi::Asset::Image.sizes = [
  { width: '200', title: '200 pixels wide' },
  { width: '400', title: '400 pixels wide' },
  { width: '600', title: '600 pixels wide' }
]
