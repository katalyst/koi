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
      params.expect(url_rewrite: %i[from to status_code active])
    end

    def set_url_rewrite
      @url_rewrite = UrlRewrite.find(params[:id])
    end

    class Collection < Admin::Collection
      config.sorting  = "from"
      config.paginate = true

      attribute :from, :string
      attribute :to, :string
      attribute :active, :boolean
    end
  end
end
