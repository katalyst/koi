# frozen_string_literal: true

Koi::Engine.routes.draw do
  resource :session, as: :admin_session, only: %i[new create destroy]

  resources :url_rewrites
  resources :admin_users
  post "clear-cache" => "application#clear_cache", :as => :clear_cache
  get "dashboard" => "application#index", :as => :dashboard
  root to: redirect("dashboard")

  constraints ->(req) { req.session[:admin_user_id].present? } do
    mount Katalyst::Content::Engine, at: "content"
    mount Katalyst::Navigation::Engine, at: "navigation"
    mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
  end
end
