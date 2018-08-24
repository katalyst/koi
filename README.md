# Koi [![Code Climate](https://codeclimate.com/github/katalyst/koi.png)](https://codeclimate.com/github/katalyst/koi) [![Dependency Status](https://gemnasium.com/katalyst/koi.png)](https://gemnasium.com/katalyst/koi) [![Stories in Ready](https://badge.waffle.io/katalyst/koi.png?label=ready&title=Ready)](https://waffle.io/katalyst/koi)

## Creating a Koi App

Run this to create a new app:

```bash
rbenv local 2.4.1
# rvm use 2.4.1
gem install rails -v 5.1.0
rails _5.1.0_ new my_app -d postgresql -m https://raw.githubusercontent.com/katalyst/koi/<BRANCH|TAG>/lib/templates/application/app.rb
```

## Development

The current version of Koi is 3.0.0, which requires Rails 5.1. Rails 4 apps should use `v2.x`. Version 2 is maintained but has no active development.

Work on version 3 should use the `3.0-dev` branch.

## License

This project rocks and uses MIT-LICENSE.

## Upgrading

See the [upgrade document](Upgrade.md) for information about breaking changes and upgrade paths.
