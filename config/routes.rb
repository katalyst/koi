# frozen_string_literal: true

Koi::Engine.routes.draw do
  resource :session, as: :admin_session, only: %i[new create destroy]

  resources :uploads, only: :create

  resources :url_rewrites
  resources :admin_users
  post "clear-cache" => "application#clear_cache", :as => :clear_cache
  get "help" => "application#help", :as => :help
  get "dashboard" => "application#index", :as => :dashboard
  root to: redirect("dashboard")

  if Rails.env.development?
    get "/styleguide" => "styleguide#index"
    get "/styleguide/:template" => "styleguide#show", template: /[-_a-z]+/
  end

  constraints ->(req) { req.session[:admin_user_id].present? } do
    mount Katalyst::Content::Engine, at: "content"
    mount Katalyst::Navigation::Engine, at: "navigation"
    mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
  end
end
