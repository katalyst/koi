# frozen_string_literal: true

module Koi
  class HeaderComponent < ViewComponent::Base
    include HeaderHelper

    renders_many :actions, "LinkComponent"
    renders_many :breadcrumbs, "LinkComponent"

    def initialize(title:)
      super()

      @title = title
    end

    class LinkComponent < ViewComponent::Base
      def initialize(name, path, **options)
        super()

        @name    = name
        @path    = path
        @options = options
      end

      def call
        link_to @name, @path, **@options
      end
    end
  end
end
