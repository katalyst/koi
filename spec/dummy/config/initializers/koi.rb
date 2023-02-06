# frozen_string_literal: true

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

# Caching enabled by default
Koi::Caching.enabled = true

# Expiry in 60.minutes by default
Koi::Caching.expires_in = 5.minutes
