Rails.application.routes.draw do
  resources :pages
  resources :news_items
  resources :super_heros

  namespace :admin do
    resources :super_heros
    resources :news_items
  end

  root to: "super_heros#index"
  mount Koi::Engine => "/admin", as: "koi_engine"
end
