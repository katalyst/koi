class NewsItem < ApplicationRecord

  has_crud navigation: true

  crud.config do
    config :admin do
      exportable true
      reportable true
      charts [{
        span:     :created_at,
        field:    :id,
        strategy: :count,
        colour:   '#f60',
        name:     'News Items Created',
        renderer: 'bar'
      }]
    end
  end

  def to_s
    title
  end

end
