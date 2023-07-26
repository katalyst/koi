# frozen_string_literal: true

module Koi
  class IndexTableComponent < ViewComponent::Base
    attr_reader :table, :pagination, :id, :pagy_id

    def initialize(collection:, id: "index-table", **options)
      super

      @id = id
      @pagy_id = "#{id}-pagination"
      @table = Katalyst::Turbo::TableComponent.new(collection:, id:, class: "index-table", caption: true, **options)
      @pagination = Katalyst::Turbo::PagyNavComponent.new(collection:, id: pagy_id) if collection.paginate?
    end

    def call
      concat(table.render_in(view_context))
      concat(pagination.render_in(view_context)) if pagination
    end
  end
end
