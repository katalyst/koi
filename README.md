# Koi [![Code Climate](https://codeclimate.com/github/katalyst/koi.png)](https://codeclimate.com/github/katalyst/koi) [![Dependency Status](https://gemnasium.com/katalyst/koi.png)](https://gemnasium.com/katalyst/koi) [![Stories in Ready](https://badge.waffle.io/katalyst/koi.png?label=ready&title=Ready)](https://waffle.io/katalyst/koi)

## Creating a Koi App

```bash
# if you don't already have koi locally, clone it
git clone git@github.com:katalyst/koi.git
# checkout the branch or tag you'd like to bootstrap your app from
cd koi && git checkout <tag|branch> && cd ..
# set/install the required version of ruby/rails
rbenv local 2.5.4
gem install rails -v 5.2.3
# bootstrap your new app!
rails _5.2.3_ new my_app -d postgresql -m ./koi/lib/templates/application/app.rb --koi-branch=<branch name>
# you can also use --koi-tag=<tag name>
```

## Development

Requirements:
* [yarn](https://yarnpkg.com/en/)  
* [foreman](https://github.com/ddollar/foreman)  

The current version of Koi is 3.1.1, which requires Rails 5.2. Rails 4 apps should use `v2.x`. Version 2 is maintained but has no active development.

There is a test dummy app available in `/spec/dummy`
Due to the requirement for webpacker, you must first install the yarn dependancies and run the server using the foreman.

```
cd spec/dummy
yarn
foreman start -f Procfile
```

## License

This project rocks and uses MIT-LICENSE.

## Upgrading

See the [upgrade document](Upgrade.md) for information about breaking changes and upgrade paths.
