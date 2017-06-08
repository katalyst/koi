%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  app/services
).each { |path| Spring.watch(path) }
