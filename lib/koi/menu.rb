module Koi
  module Menu
    mattr_accessor :items
    @@items = {}

    mattr_accessor :advanced
    @@items = {}

    mattr_accessor :filterable
    @@filterable = true
  end
end
