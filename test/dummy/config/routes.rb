Rails.application.routes.draw do
  devise_for :users

  resources :users, path: :members
  resources :pages
  resources :news_items
  resources :super_heros

  namespace :admin do
    resources :users, path: :members
    resources :super_heros
    resources :news_items
  end

  constraints :subdomain => "mobile" do
    scope :module => "mobile", :as => "mobile" do
      root to: "application#index"
    end
  end

  root to: "super_heros#index"

  mount Koi::Engine => "/admin", as: "koi_engine"
end
