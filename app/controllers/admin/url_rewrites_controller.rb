# frozen_string_literal: true

module Admin
  class UrlRewritesController < ApplicationController
    before_action :set_url_rewrite, only: %i[show edit update destroy]

    def index
      @url_rewrites ||= UrlRewrite.all

      @url_rewrites = @url_rewrites.admin_search(params[:search]) if params[:search]

      sort, @url_rewrites = table_sort(@url_rewrites)
      pagy, @url_rewrites = pagy(@url_rewrites)

      @url_rewrites = @url_rewrites.alphabetical

      render :index, locals: { url_rewrites: @url_rewrites, sort:, pagy: }
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
        render :new, status: :unprocessable_entity, locals: { url_rewrite: @url_rewrite }
      end
    end

    def update
      @url_rewrite.attributes = url_rewrite_params

      if @url_rewrite.save
        redirect_to admin_url_rewrite_path(@url_rewrite)
      else
        render :edit, status: :unprocessable_entity, locals: { url_rewrite: @url_rewrite }
      end
    end

    def destroy
      @url_rewrite.destroy!

      redirect_to admin_url_rewrites_path
    end

    private

    def url_rewrite_params
      params.require(:url_rewrite).permit(:from, :to)
    end

    def set_url_rewrite
      @url_rewrite = UrlRewrite.find(params[:id])
    end
  end
end
