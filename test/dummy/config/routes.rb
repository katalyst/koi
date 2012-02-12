Rails.application.routes.draw do
  resources :super_heros
  namespace :admin do resources :super_heros end
  mount Koi::Engine => "/admin", as: "koi_engine"
  root to: "super_heros#index"
end
