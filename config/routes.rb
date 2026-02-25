# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: %i[new create destroy] do
      # JWT tokens contain periods
      resources :tokens, param: :token, only: %i[show update], token: /[^\/]+/
    end

    resources :admin_users, shallow: true do
      get :archived, on: :collection
      put :archive, on: :collection
      put :restore, on: :collection

      resources :credentials, only: %i[show new create update destroy]
      resource :otp, only: %i[new create destroy]
      resources :tokens, only: %i[create]
    end

    resource :cache, only: %i[destroy]
    resource :dashboard, only: %i[show]
    resources :well_knowns
    resources :url_rewrites

    root to: redirect("admin/dashboard")
  end

  scope :admin do
    mount Katalyst::Content::Engine, at: "content"
    mount Katalyst::Navigation::Engine, at: "navigation"
    mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
  end

  resources :well_knowns, path: ".well-known", param: :name, only: %i[show], name: /.+/
end
