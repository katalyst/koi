class NewsItem < ActiveRecord::Base

  has_crud

  crud.config do
    config :admin do
      exportable true
    end
  end

  def to_s
    title
  end

end

