# Koi::Asset::Document.extensions = [:pdf, :doc]

Koi::Menu.items = {
  "Super Heros"  => "/admin/super_heros",
  "Admins"       => "/admin/site_users",
  "News"         => "/admin/news_items",
  "Categories"   => "/admin/categories",
  "URL History"  => "/admin/friendly_id_slugs",
  "URL Rewriter" => "/admin/url_rewrites"
}

Koi::Settings.collection = {
  title:       { label: "Title",       value: "title", field_type: 'text' },
  description: { label: "Description", value: "title", field_type: 'rich_text' }
}

Koi::Settings.resource = {
  banners:     { label: "Banners",     field_type: "radio",     value: 'Test' },
  title:       { label: "Title",       field_type: "text",      value: 'Test' },
  description: { label: "Description", field_type: "rich_text", value: 'Test' }
}

Koi::Asset::Image.sizes = [
  { width: '200', title: '200 pixels wide' },
  { width: '400', title: '400 pixels wide' },
  { width: '600', title: '600 pixels wide' }
]
