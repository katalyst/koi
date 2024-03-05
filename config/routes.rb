# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: %i[new create destroy]
    resource :passkey_resets, only: %i[new edit create update]
    resources :url_rewrites
    resources :admin_users do
      resources :credentials, only: %i[new create destroy]
    end

    resource :cache, only: %i[destroy]
    resource :dashboard, only: %i[show]

    root to: redirect("admin/dashboard")
  end

  scope :admin do
    constraints ->(req) { req.session[:admin_user_id].present? } do
      mount Katalyst::Content::Engine, at: "content"
      mount Katalyst::Navigation::Engine, at: "navigation"
      mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
    end
  end
end
