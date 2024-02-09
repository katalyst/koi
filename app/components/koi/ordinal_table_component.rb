# frozen_string_literal: true

module Koi
  class OrdinalTableComponent < Tables::TableComponent
    include Katalyst::Tables::Orderable

    def initialize(collection:,
                   id: "index-table",
                   url: [:order, :admin, collection],
                   scope: "order[#{collection.model_name.plural}]",
                   **options)
      super(collection:, id:, class: "index-table", caption: true, **options)

      @url   = url
      @scope = scope
    end

    def before_render
      with_orderable(url: @url, scope: @scope) unless orderable?
    end

    def call
      concat(render_parent)
      concat(orderable)
    end
  end
end
