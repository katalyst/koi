# frozen_string_literal: true

module Admin
  class UrlRewritesController < ApplicationController
    before_action :set_url_rewrite, only: %i[show edit update destroy]

    def index
      collection = Collection.new.with_params(params).apply(UrlRewrite.strict_loading)

      render locals: { collection: }
    end

    def show
      render :show, locals: { url_rewrite: @url_rewrite }
    end

    def new
      @url_rewrite = UrlRewrite.new
      render :new, locals: { url_rewrite: @url_rewrite }
    end

    def edit
      render :edit, locals: { url_rewrite: @url_rewrite }
    end

    def create
      @url_rewrite = UrlRewrite.new(url_rewrite_params)

      if @url_rewrite.save
        redirect_to admin_url_rewrite_path(@url_rewrite)
      else
        render :new, status: :unprocessable_content, locals: { url_rewrite: @url_rewrite }
      end
    end

    def update
      @url_rewrite.attributes = url_rewrite_params

      if @url_rewrite.save
        redirect_to admin_url_rewrite_path(@url_rewrite)
      else
        render :edit, status: :unprocessable_content, locals: { url_rewrite: @url_rewrite }
      end
    end

    def destroy
      @url_rewrite.destroy!

      redirect_to admin_url_rewrites_path
    end

    private

    def url_rewrite_params
      params.require(:url_rewrite).permit(:from, :to, :status_code, :active)
    end

    def set_url_rewrite
      @url_rewrite = UrlRewrite.find(params[:id])
    end

    class Collection < Katalyst::Tables::Collection::Base
      attribute :search, :string, default: ""
      attribute :scope, :string, default: "active"

      config.sorting  = "from"
      config.paginate = true

      def filter
        self.items = items.admin_search(search) if search.present?

        self.items = case scope&.to_sym
                     when :active
                       items.where(active: true)
                     when :inactive
                       items.where(active: false)
                     else
                       items
                     end
      end
    end
  end
end
