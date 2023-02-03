# frozen_string_literal: true

Koi::Menu.modules = {
  "Articles" => "/admin/articles",
}

Koi::Menu.advanced = {
  "Admin Users"  => "/admin/admin_users",
  "URL Rewriter" => "/admin/url_rewrites",
}

# Caching enabled by default
Koi::Caching.enabled = true

# Expiry in 60.minutes by default
Koi::Caching.expires_in = 5.minutes
