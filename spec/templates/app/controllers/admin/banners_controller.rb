# frozen_string_literal: true

module Admin
  class BannersController < ApplicationController
    before_action :set_banner, only: %i[show edit update destroy]

    def index
      collection = Collection.new.with_params(params).apply(::Banner.with_attached_image.strict_loading)

      render :index, locals: { collection: }
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
        render :new, locals: { banner: @banner }, status: :unprocessable_content
      end
    end

    def update
      if @banner.update(banner_params)
        redirect_to action: :show
      else
        render :edit, locals: { banner: @banner }, status: :unprocessable_content
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

    def banner_params
      params.expect(banner: %i[name image ordinal])
    end

    def order_params
      params.expect(order: { banners: [[:ordinal]] })
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_banner
      @banner = ::Banner.find(params[:id])
    end

    class Collection < Admin::Collection
      attribute :name, :string
      attribute :status, :enum
      attribute :created_at, :date
    end
  end
end
