# frozen_string_literal: true

Koi::Menu.items = {
  "Modules"  => {},
  "Advanced" => {
    "Admin Users"  => "/admin/admin_users",
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
]

# Caching enabled by default
Koi::Caching.enabled = true

# Expiry in 60.minutes by default
Koi::Caching.expires_in = 5.minutes
