# frozen_string_literal: true

module Koi
  class IndexTableComponent < ViewComponent::Base
    attr_reader :id, :pagy_id

    # Use the Koi::Tables::TableComponent to support custom header and body row components
    renders_one :table, Koi::Tables::TableComponent
    renders_one :pagination, Katalyst::Turbo::PagyNavComponent

    def initialize(collection:, id: "index-table", **options)
      super

      @id      = id
      @pagy_id = "#{id}-pagination"

      with_table(collection:, id:, class: "index-table", caption: true, **options)
      with_pagination(collection:, id: pagy_id) if collection.paginate?
    end

    def call
      concat(table)
      concat(pagination)
    end
  end
end
