# frozen_string_literal: true

module Admin
  class WellKnownsController < ApplicationController
    before_action :set_well_known, only: %i[show edit update destroy]

    attr_reader :collection, :well_known

    def index
      @collection = Collection.new.with_params(params).apply(WellKnown.strict_loading.all)

      render locals: { collection: }
    end

    def show
      render locals: { well_known: }
    end

    def new
      @well_known = WellKnown.new

      render locals: { well_known: }
    end

    def edit
      render locals: { well_known: }
    end

    def create
      @well_known = WellKnown.new(well_known_params)

      if @well_known.save
        redirect_to admin_well_known_path(well_known), status: :see_other
      else
        render :new, locals: { well_known: }, status: :unprocessable_content
      end
    end

    def update
      if well_known.update(well_known_params)
        redirect_to admin_well_known_path(well_known), status: :see_other
      else
        render :edit, locals: { well_known: }, status: :unprocessable_content
      end
    end

    def destroy
      @well_known.destroy!

      redirect_to admin_well_knowns_path, status: :see_other
    end

    private

    def set_well_known
      @well_known = ::WellKnown.find(params[:id])
    end

    def well_known_params
      params.expect(well_known: %i[name purpose content_type content])
    end

    class Collection < Admin::Collection
      config.sorting  = :name
      config.paginate = true

      attribute :name, :string
      attribute :purpose, :string
      attribute :content_type, :enum
      attribute :content, :string
    end
  end
end
