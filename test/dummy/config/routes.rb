Rails.application.routes.draw do
  constraints :subdomain => "mobile" do
    scope :module => "mobile", :as => "mobile" do
      resources :pages
      root to: "application#index"
    end
  end

  devise_for :users

  resources :users, path: :members
  resources :pages
  resources :news_items
  resources :super_heros

  namespace :admin do
    resources :users, path: :members
    resources :super_heros
    resources :news_items
    resources :categories do
      collection { put 'sort' }
      resources :products 
    end
  end

  root to: "super_heros#index"

  mount Koi::Engine => "/admin", as: "koi_engine"
end
