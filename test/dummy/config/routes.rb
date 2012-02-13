Rails.application.routes.draw do
  resources :news_items
  resources :super_heros

  namespace :admin do
    resources :super_heros
    resources :news_items
  end

  mount Koi::Engine => "/admin", as: "koi_engine"
  root to: "super_heros#index"
end
