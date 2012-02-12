Rails.application.routes.draw do
  namespace(:admin) { resources :news_items }

  resources :news_items

  resources :super_heros
  namespace :admin do resources :super_heros end
  mount Koi::Engine => "/admin", as: "koi_engine"
  root to: "super_heros#index"
end
