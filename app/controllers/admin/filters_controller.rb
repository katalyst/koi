# frozen_string_literal: true

module Admin
  class FiltersController < ApplicationController
    before_action :set_model

    def show
      if params[:key].blank?
        render :attributes, locals: {
          attributes: AttributeBuilder.new(@model).attributes,
        }
      else
        render :values, locals: {
          key:    params[:key],
          values: @model.limit(10).pluck(params[:key]),
        }
      end
    end

    private

    def set_model
      @model = params[:model].safe_constantize

      raise ActiveRecord::RecordNotFound unless @model.is_a?(Class) && @model < ActiveRecord::Base
    end

    class AttributeBuilder
      SUPPORTED_COLUMN_TYPES = [:string].freeze

      def initialize(model)
        @model = model
      end

      def attributes
        @model.columns
          .select { |column| column.type.in?(SUPPORTED_COLUMN_TYPES) }
          .map(&:name)
      end
    end
  end
end
