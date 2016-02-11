# Koi [![Code Climate](https://codeclimate.com/github/katalyst/koi.png)](https://codeclimate.com/github/katalyst/koi) [![Dependency Status](https://gemnasium.com/katalyst/koi.png)](https://gemnasium.com/katalyst/koi) [![Stories in Ready](https://badge.waffle.io/katalyst/koi.png?label=ready&title=Ready)](https://waffle.io/katalyst/koi)

## Creating a Koi App

Run this to create a new app:

```bash
gem install rails -v 4.2.1
rails _4.2.1_ new my_app -d postgresql -m https://raw.github.com/katalyst/koi/v2.2.0/lib/templates/application/app.rb
```

## License

This project rocks and uses MIT-LICENSE.

## Upgrading

### v2.2.0

Koi::Menu format has changed from:

```
Koi::Menu.items = {
  "News"         => "/admin/news_items",
  "Categories"   => "/admin/categories"
}
```

To:

```
Koi::Menu.items = {
  "Modules": {
    "News"         => "/admin/news_items",
    "Categories"   => "/admin/categories"
  },
  "Heroes": {
    "Super Heros"  => "/admin/super_heros",
    "Kid Heros"    => "/admin/kid_heros"
  },
  "Advanced": {
    "Admins"       => "/admin/site_users",
    "URL History"  => "/admin/friendly_id_slugs",
    "URL Rewriter" => "/admin/url_rewrites"
  }
}
```
