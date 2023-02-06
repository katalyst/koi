# frozen_string_literal: true

Rails.application.routes.draw do
  resources :products

  constraints subdomain: "mobile" do
    scope module: "mobile", as: "mobile" do
      resources :legacy_pages
      root to: "application#index"
    end
  end

  devise_for :users

  resources :categories do
    resources :products, except: %i[new create edit update destroy]
  end

  resources :users, path: :members
  resources :legacy_pages, only: %i[index show], as: :koi_pages
  resources :news_items
  resources :super_heros
  resources :kid_heros

  namespace :admin do
    resources :users, path: :members
    resources :super_heros
    resources :kid_heros
    resources :news_items
    resources :product_images
    resources :categories do
      collection { put "sort" }
      resources :products do
        collection { put "sort" }
      end
    end
  end

  root to: redirect("/home-page")

  mount Koi::Engine => "/admin", as: "koi_engine"

  get "/:id" => "legacy_pages#show", as: :legacy_page
end
