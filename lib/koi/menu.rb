module Koi
  module Menu
    mattr_accessor :items
    @@items = {}

    mattr_accessor :advanced
    @@items = {}

    mattr_accessor :filterable
    @@filterable = true

    mattr_accessor :filter_urls
    @@filter_urls = true
  end
end
