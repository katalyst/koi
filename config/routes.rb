# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: %i[new create destroy]

    resources :url_rewrites
    resources :admin_users do
      resources :credentials, only: %i[new create destroy]
    end

    resource :cache, only: %i[destroy]
    resource :dashboard, only: %i[show]

    constraints ->(req) { req.session[:admin_user_id].present? } do
      mount Katalyst::Content::Engine, at: "content"
      mount Katalyst::Navigation::Engine, at: "navigation"
      mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
    end

    root to: redirect("admin/dashboard")
  end
end
