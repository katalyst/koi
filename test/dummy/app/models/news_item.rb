class NewsItem < ActiveRecord::Base
  has_crud

  crud.config do
    config :admin do
      exportable true
    end
  end
end

