# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: %i[new create destroy] do
      # JWT tokens contain periods
      resources :tokens, param: :token, only: %i[show update], token: /[^\/]+/
    end

    resources :url_rewrites
    resources :admin_users do
      resources :credentials, only: %i[new create destroy]
      resource :otp, only: %i[new create destroy]
      resources :tokens, only: %i[create]
      get :archived, on: :collection
      put :archive, on: :collection
      put :restore, on: :collection
    end

    resource :cache, only: %i[destroy]
    resource :dashboard, only: %i[show]

    root to: redirect("admin/dashboard")
  end

  scope :admin do
    mount Katalyst::Content::Engine, at: "content"
    mount Katalyst::Navigation::Engine, at: "navigation"
    mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
  end
end
