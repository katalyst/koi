# frozen_string_literal: true

class ArticlesController < ApplicationController
  helper Katalyst::Content::FrontendHelper
  include Pagy::Backend

  before_action :set_article, only: %i[show preview]

  def index
    @articles = Article.published.chronological

    @pagy, @articles = pagy(@articles)

    render locals: { articles: @articles, pagy: @pagy }
  end

  def show
    render locals: { article: @article, version: @article.published_version }
  end

  def preview
    return redirect_to action: :show if @article.state == :published

    render :show, locals: {
      article: @article,
      version: @article.draft_version,
    }
  end

  private

  def set_article
    @article = Article.find_by!(slug: params[:slug])
  end
end
