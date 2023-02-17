# frozen_string_literal: true

class ArticlesController < ApplicationController
  helper Katalyst::Content::FrontendHelper

  def index
    @articles = Article.published

    render locals: { articles: @articles }
  end

  def show
    @article = Article.find_by(params[:id])

    render locals: { article: @article, version: @article.published_version }
  end

  def preview
    @article = Article.find_by(params[:id])

    return redirect_to action: :show if @article.state == :published

    render :show, locals: {
      article: @article,
      version: @article.draft_version,
    }
  end
end
