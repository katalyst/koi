# frozen_string_literal: true

module Koi
  class CsvComponent < ViewComponent::Base
    attr_reader :collection, :id, :partial, :selection

    delegate :items, :sort, :pagy, :paginated?, to: :collection

    def initialize(collection, partial: "table")
      @collection = collection
      @partial    = partial
    end

    def call
      render(partial:, formats: :csv, locals: { items: })
    end
  end
end
