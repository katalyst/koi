# frozen_string_literal: true

Koi::Engine.routes.draw do
  devise_for :admins, class_name:  "AdminUser",
                      controllers: {
                        passwords: "koi/passwords",
                        sessions:  "koi/sessions",
                      }

  resources :uploads, only: :create

  resources :assets
  resources :images
  resources :documents

  resources :translations, path: :site_settings do
    get :seed, on: :collection
  end
  resources :settings do
    put :update_multiple, on: :collection
  end
  resources :pages
  resources :url_rewrites
  resources :friendly_id_slugs
  resources :admins, path: :site_users
  resources :module_nav_items
  resources :folder_nav_items
  resources :alias_nav_items
  resources :resource_nav_items
  resources :nav_items do
    get :toggle, on: :member
    collection do
      get :sitemap
      post :savesort
    end
  end
  post "clear-cache" => "application#clear_cache", :as => :clear_cache
  get  "help" => "application#help", :as => :help
  get  "dashboard" => "application#index", :as => :dashboard
  root to: "application#login"

  if Rails.env.development?
    get "/styleguide"           => "styleguide#index"
    get "/styleguide/:template" => "styleguide#show", template: /[-_a-z]+/
  end

  authenticate :admin, ->(admin) { admin.present? } do
    mount Katalyst::Navigation::Engine, at: "navigation"
    mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
  end
end
