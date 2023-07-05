# frozen_string_literal: true

module Admin
  class Collection
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveSupport::Configurable
    include Pagy::Backend
    include Katalyst::Tables::Backend

    attr_accessor :params, :items, :pagination, :sorting

    attribute :search, :string
    attribute :sort, :string
    attribute :page, :integer
    attribute :per, :integer

    config_accessor :default_sort, default: "unset"

    delegate :model, :each, to: :items

    def initialize(params, default_sort: config.default_sort)
      super(**params.permit(self.class.attribute_types.keys))

      raise ArgumentError, "Default sort scope is unset" if !default_sort.nil? && !default_sort.is_a?(Symbol)

      @default_sort = default_sort
      @params       = params
    end

    def apply(items)
      @items = items

      with_filters unless selection?
      with_selection if selection?
      with_sort
      with_pagination unless selection? || export?

      self
    end

    def with_pagination
      @pagination, @items = pagy(@items)

      self
    end

    def with_sort
      @sorting, @items = table_sort(@items)

      # default sort after main sort as a fallback
      @items           = items.public_send(@default_sort) if @default_sort

      self
    end

    def export?
      params[:format] == "csv"
    end

    def paginated?
      pagination.present?
    end

    def selection?
      params[:id].present?
    end

    def with_filters
      self.items = items.admin_search(search) if search.present?
    end

    def with_selection
      self.items = items.where(id: params[:id].split(","))
    end
  end
end
