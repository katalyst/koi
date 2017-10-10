# Koi [![Code Climate](https://codeclimate.com/github/katalyst/koi.png)](https://codeclimate.com/github/katalyst/koi) [![Dependency Status](https://gemnasium.com/katalyst/koi.png)](https://gemnasium.com/katalyst/koi) [![Stories in Ready](https://badge.waffle.io/katalyst/koi.png?label=ready&title=Ready)](https://waffle.io/katalyst/koi)

## Creating a Koi App

Run this to create a new app:

```bash
rbenv local 2.4.1
# rvm use 2.4.1
gem install rails -v 5.1.0
rails _5.1.0_ new my_app -d postgresql -m https://raw.githubusercontent.com/katalyst/koi/<BRANCH|TAG>/lib/templates/application/app.rb
```

## Running in development

Requirements:
* [yarn](https://yarnpkg.com/en/)  
* [foreman](https://github.com/ddollar/foreman)  

There is a test dummy app available in `/test/dummy` 
Due to the requirement for webpacker, you must first install the yarn dependancies and run the server using the foreman. 

```
cd test/dummy  
yarn
foreman start -f Procfile
```

## License

This project rocks and uses MIT-LICENSE.

## Upgrading

See the [upgrade document](Upgrade.md) for information about breaking changes and upgrade paths.  
