Rails.application.routes.draw do
  resources :super_heros
  namespace :admin do resources :super_heros end
  mount Koi::Engine => "/admin"
  root to: "super_heros#index"
end
