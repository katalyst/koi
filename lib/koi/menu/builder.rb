# frozen_string_literal: true

module Koi
  module Menu
    class Builder
      def initialize
        @menu  = Katalyst::Navigation::Menu.new
        @index = 0
        @depth = 0
      end

      def add_items(items)
        items.each do |k, v|
          add_item(k, v)
        end
      end

      def add_item(title, value)
        if value.is_a?(Hash)
          add_menu(title:) do |b|
            value.each do |k, v|
              b.add_item(k, v)
            end
          end
        else
          add_link(title:, url: value)
        end
      end

      def add_menu(title:, **, &)
        @menu.items.build(type:  Katalyst::Navigation::Heading.name,
                          title:,
                          **,
                          index: @index,
                          depth: @depth)
        @index += 1
        @depth += 1
        yield(self)
        @depth -= 1
      end

      def add_link(title:, url:, **)
        @menu.items.build(type:  Katalyst::Navigation::Link.name,
                          title:,
                          url:,
                          **,
                          index: @index,
                          depth: @depth)
        @index += 1
      end

      def add_button(title:, url:, **)
        @menu.items.build(type:  Katalyst::Navigation::Button.name,
                          title:,
                          url:,
                          **,
                          index: @index,
                          depth: @depth)
        @index += 1
      end

      def render
        @menu.published_version = @menu.build_draft_version
        @menu
      end
    end
  end
end
