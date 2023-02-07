# frozen_string_literal: true

Koi::Engine.routes.draw do
  devise_for :admins, class_name:  "AdminUser",
                      controllers: {
                        passwords: "koi/passwords",
                        sessions:  "koi/sessions",
                      }

  resources :uploads, only: :create

  resources :url_rewrites
  resources :admin_users
  post "clear-cache" => "application#clear_cache", :as => :clear_cache
  get  "help" => "application#help", :as => :help
  get  "dashboard" => "application#index", :as => :dashboard
  root to: "application#login"

  if Rails.env.development?
    get "/styleguide"           => "styleguide#index"
    get "/styleguide/:template" => "styleguide#show", template: /[-_a-z]+/
  end

  authenticate :admin, ->(admin) { admin.present? } do
    mount Katalyst::Content::Engine, at: "content"
    mount Katalyst::Navigation::Engine, at: "navigation"
    mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
  end
end
