# Koi::Asset::Document.extensions = [:pdf, :doc]

Koi::Menu.items = {
  "Super Heros" => "/admin/super_heros",
  "Admins" => "/admin/site_users",
  "News" => "/admin/news_items",
  "Categories" => "/admin/categories"
}

Koi::Settings.collection = {
  banners: { label: "Banners", field_type: "images" },
  title:   { label: "Title", value: "title" }
}

Koi::Settings.resource = {
  banners: { label: "Banners", field_type: "images" }
}

Koi::Asset::Image.sizes = [
  { width:    '200' , title: '200 pixels wide' },
  { width:    '400' , title: '400 pixels wide' },
  { width:    '600' , title: '600 pixels wide' }
]
