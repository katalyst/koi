# frozen_string_literal: true

module Admin
  class BannersController < ApplicationController
    before_action :set_banner, only: %i[show edit update destroy]

    def index
      collection = Collection.new.with_params(params).apply(::Banner.strict_loading)
      table      = Koi::OrdinalTableComponent.new(collection:)

      respond_to do |format|
        format.turbo_stream { render table } if self_referred?
        format.html { render :index, locals: { table:, collection: } }
      end
    end

    def show
      render locals: { banner: @banner }
    end

    def new
      render locals: { banner: ::Banner.new }
    end

    def edit
      render locals: { banner: @banner }
    end

    def create
      @banner = ::Banner.new(banner_params)

      if @banner.save
        redirect_to [:admin, @banner]
      else
        render :new, locals: { banner: @banner }, status: :unprocessable_entity
      end
    end

    def update
      if @banner.update(banner_params)
        redirect_to action: :show
      else
        render :edit, locals: { banner: @banner }, status: :unprocessable_entity
      end
    end

    def destroy
      @banner.destroy

      redirect_to action: :index
    end

    def order
      order_params[:banners].each do |id, attrs|
        Banner.find(id).update(attrs)
      end

      redirect_back(fallback_location: admin_banners_path, status: :see_other)
    end

    private

    # Only allow a list of trusted parameters through.
    def banner_params
      params.require(:banner).permit(:name, :image, :ordinal)
    end

    def order_params
      params.require(:order).permit(banners: [:ordinal])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_banner
      @banner = ::Banner.find(params[:id])
    end

    class Collection < Katalyst::Tables::Collection::Base
      attribute :search, :string

      def filter
        self.items = items.admin_search(search) if search.present?
      end
    end
  end
end
