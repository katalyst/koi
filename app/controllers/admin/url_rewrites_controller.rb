# frozen_string_literal: true

module Admin
  class UrlRewritesController < ApplicationController
    before_action :set_url_rewrite, only: %i[show edit update destroy]

    attr_reader :collection, :url_rewrite

    def index
      @collection = Collection.new.with_params(params).apply(UrlRewrite.strict_loading.all)

      render locals: { collection: }
    end

    def show
      render locals: { url_rewrite: }
    end

    def new
      @url_rewrite = UrlRewrite.new

      render locals: { url_rewrite: }
    end

    def edit
      render locals: { url_rewrite: }
    end

    def create
      @url_rewrite = UrlRewrite.new(url_rewrite_params)

      if @url_rewrite.save
        redirect_to admin_url_rewrite_path(url_rewrite), status: :see_other
      else
        render :new, locals: { url_rewrite: }, status: :unprocessable_content
      end
    end

    def update
      if url_rewrite.update(url_rewrite_params)
        redirect_to admin_url_rewrite_path(url_rewrite), status: :see_other
      else
        render :edit, locals: { url_rewrite: }, status: :unprocessable_content
      end
    end

    def destroy
      @url_rewrite.destroy!

      redirect_to admin_url_rewrites_path, status: :see_other
    end

    private

    def set_url_rewrite
      @url_rewrite = ::UrlRewrite.find(params[:id])
    end

    def url_rewrite_params
      params.expect(url_rewrite: %i[from to active status_code])
    end

    class Collection < Admin::Collection
      config.sorting  = :from
      config.paginate = true

      attribute :from, :string
      attribute :to, :string
      attribute :active, :boolean
      attribute :status_code, :enum
    end
  end
end
