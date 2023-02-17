# frozen_string_literal: true

module Admin
  class ArticlesController < ApplicationController
    helper Katalyst::Content::EditorHelper

    before_action :set_article, only: %i[show edit update]

    def index
      @articles = Article.all

      @articles = sort_and_paginate(@articles)

      render :index, locals: { articles: @articles, sort: @sort, pagy: @pagy }
    end

    def show
      render :show, locals: { article: @article }
    end

    def edit
      render :edit, locals: { article: @article }
    end

    def update
      @article.attributes = article_attributes

      unless @article.valid?
        case previous_action
        when "show"
          # content cannot be saved, replace error frame
          return render turbo_stream: helpers.content_editor_errors(container: @article),
                        status:       :unprocessable_entity
        when "edit"
          # form errors, re-render edit
          return render previous_action, locals: { donation_target: @article }, status: :unprocessable_entity
        end
      end

      case params[:commit]
      when "publish"
        @article.save!
        @article.publish!
      when "save"
        @article.save!
      when "revert"
        @article.revert!
      end

      return redirect_to [:admin, @article] if previous_action == "edit"

      redirect_back fallback_location: [:admin, @article]
    end

    def new
      @article = Article.new

      render :new, locals: { article: @article }
    end

    def create
      @article = Article.new(article_attributes)

      if @article.save
        redirect_to admin_article_path(@article)
      else
        render :new, locals: { article: @article }, status: :unprocessable_entity
      end
    end

    private

    def previous_action
      previous = request.referer&.split("/")&.last
      %w[show edit].include?(previous) ? previous : "show"
    end

    def set_article
      @article = Article.find(params[:id])
    end

    def article_attributes
      params.require(:article).permit(:title,
                                      :show_title,
                                      :slug,
                                      :short_description,
                                      :image,
                                      { items_attributes: %i[id index depth] })
    end
  end
end
