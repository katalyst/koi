# frozen_string_literal: true

module Koi
  class TableComponent < ViewComponent::Base
    include Katalyst::Tables::Frontend
    include Pagy::Frontend
    include Turbo::StreamsHelper

    def self.with(context, items, paginate: true, selection: true, sort:, **options)
      collection = Collection.new(items).tap do |collection|
        collection.with_sort(context, sort) if sort
        collection.with_pagination(context) if paginate
      end

      new(collection, **options)
    end

    attr_reader :collection, :id, :partial, :selection

    delegate :items, :sort, :pagy, :paginated?, to: :collection

    def initialize(collection, id: "table", partial: "table", **html_options)
      @collection   = collection
      @id           = id
      @partial      = partial
      @html_options = html_options

      @selection = SelectionComponent.new(parent: self)
    end

    def call
      content = tag.div(id:, class: @html_options.delete(:class) || "stack", **@html_options) do
        render(partial:, locals: { collection: items, sort:, selection: }, formats: :html) + pagination
      end

      view_context.controller.respond_to do |format|
        format.html { content }
        format.turbo_stream { turbo_stream.replace(id, content) }
      end
    end

    def pagination
      pagy_nav(pagy).html_safe if paginated?
    end

    class SelectionComponent < ViewComponent::Base

      delegate_missing_to :@form
      def initialize(parent:)
        super

        @parent = parent
      end

      def id
        "#{@parent.id}_selection"
      end

      def call
        form_with(id:, data: { controller: "selection", action: "selection#submit" }) do |form|
          @form = form
          content
        end
      end
    end

    class Collection
      attr_accessor :items, :pagy, :sort

      def initialize(items)
        @items = items
      end

      def with_pagination(context)
        @pagy, @items = context.send(:pagy, @items)

        self
      end

      def with_sort(context, sort)
        @sort, @items = context.table_sort(@items)

        raise ArgumentError, "Default sort scope not provided" if sort && !sort.is_a?(Symbol)

        # default sort after main sort as a fallback
        @items = @items.public_send(sort) if sort

        self
      end

      def paginated?
        pagy.present?
      end
    end
  end
end
