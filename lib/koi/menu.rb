# frozen_string_literal: true

require "koi/menu/builder"

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

    def menu
      builder = Builder.new
      items.each { |title, value| builder.add_item(title, value) }
      builder.render
    end

    module_function(:menu)
  end
end
