# frozen_string_literal: true

module Koi
  class TableBuilderComponent < ViewComponent::Base
    def initialize(collection:, sort:, **html_options)
      @collection   = collection
      @sort         = sort
      @html_options = html_options
    end

    def call
      tag.table(**@html_options) do
        tag.thead do
          concat(render_header)
        end + tag.tbody do
          @collection.each do |record|
            concat(render_row(record))
          end
        end
      end
    end

    def render_header
      # extract the column's block from the slot and pass it to the cell for rendering
      TableHeaderRowComponent.new.render_in(view_context, &@__vc_render_in_block)
    end

    def render_row(object)
      # extract the column's block from the slot and pass it to the cell for rendering
      block = @__vc_render_in_block
      TableBodyRowComponent.new(object).render_in(view_context) do |row|
        block.call(row, object)
      end
    end

    class TableHeaderRowComponent < ViewComponent::Base
      renders_many :columns, "::Koi::TableBuilderComponent::TableHeaderCellComponent"

      def call
        content
        tag.tr do
          columns.each do |column|
            concat(render(column))
          end
        end
      end
    end

    class TableHeaderCellComponent < ViewComponent::Base
      def initialize(attribute, **html_options)
        @attribute    = attribute
        @html_options = html_options
      end

      def call
        tag.th(**@html_options) do
          @attribute.to_s.humanize
        end
      end
    end

    class TableBodyRowComponent < ViewComponent::Base
      renders_many :columns, ->(attribute, **html_options) do
        Koi::TableBuilderComponent::TableBodyCellComponent.new(attribute, @object, **html_options)
      end

      def initialize(object)
        @object = object
      end

      def call
        content
        tag.tr do
          columns.each do |column|
            concat(column.to_s)
          end
        end
      end
    end

    class TableBodyCellComponent < ViewComponent::Base
      def initialize(attribute, object, **html_options)
        @attribute    = attribute
        @object       = object
        @html_options = html_options
      end

      def object
        @object
      end

      def call
        tag.td(**@html_options) do
          content? ? content : value
        end
      end

      def value
        @object.send(@attribute)
      end
    end
  end
end
