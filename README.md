# Koi [![Code Climate](https://codeclimate.com/github/katalyst/koi.png)](https://codeclimate.com/github/katalyst/koi) [![Dependency Status](https://gemnasium.com/katalyst/koi.png)](https://gemnasium.com/katalyst/koi)

## Creating a Koi App

Run this to create a new app:

```bash
gem install rails -v 3.2.22.5
rails _3.2.22.5_ new my_app -d mysql -m https://raw.github.com/katalyst/koi/v1.2.1/lib/templates/application/app.rb
```

## Installing old rails versions on MacOS

Rails 3.x depends on Ruby <= 2.3.8 and OpenSSL 1.0. These are well out of their support windows so they are hard to
install on modern MacOS systems.

### OpenSSL 1.0

There's a brew tap available from the rbenv team:

```
brew install rbenv/tap/openssl@1.0
```

### Ruby 2.3 and below

```
RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.0)" rbenv install 2.3.8
```

## License

This project rocks and uses MIT-LICENSE.
