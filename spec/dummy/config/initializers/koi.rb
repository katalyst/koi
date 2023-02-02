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

# Caching enabled by default
Koi::Caching.enabled = true

# Expiry in 60.minutes by default
Koi::Caching.expires_in = 5.minutes
