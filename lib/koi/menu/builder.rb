# frozen_string_literal: true

module Koi
  module Menu
    class Builder
      def initialize
        @menu  = Katalyst::Navigation::Menu.new
        @index = 0
        @depth = 0
      end

      def add_item(label, value)
        if value.is_a?(Hash)
          add_menu(label, value)
        else
          add_link(label, value)
        end
      end

      def add_link(title, url)
        @menu.items.build(type:  Katalyst::Navigation::Link.name,
                          title: title,
                          url:   url,
                          index: @index,
                          depth: @depth)
        @index += 1
      end

      def add_menu(title, children)
        add_link(title, "")
        @depth += 1
        children.each { |k, v| add_item(k, v) }
        @depth -= 1
      end

      def render
        @menu.published_version = @menu.build_draft_version
        @menu
      end
    end
  end
end
