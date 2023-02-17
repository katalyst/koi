# frozen_string_literal: true

class ArticleSeeds
  class << self
    def run
      create_article(title: "Article 1", heading: "Article 1", content: "Hello")
      create_article(title: "Article 2", heading: "Article 2", content: "Hello")
    end

    def create_article(title:, heading:, content:)
      return if Article.exists?(slug: title.parameterize)

      article = Article.new(title:, slug: title.parameterize)
      article.save!
      item = Katalyst::Content::Content.new(content:, heading:, container: article)
      item.background = Katalyst::Content.config.backgrounds.sample
      item.save!
      article.items            = [item]
      article.items_attributes = article.items.map.with_index { |i, index| { id: i.id, index:, depth: 0 } }
      article.save!
      article.publish!

      puts "created article: #{article.title}"
    end
  end
end
