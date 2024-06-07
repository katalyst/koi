# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resource :session, only: %i[new create destroy] do
      post :accept, to: "tokens#update"
    end

    resources :url_rewrites
    resources :admin_users do
      resources :credentials, only: %i[new create destroy]
      post :invite, on: :member, to: "tokens#create"
    end

    resources :filters, param: :model, only: %i[show]

    # JWT tokens have dots(represents the 3 parts of data) in them, so we need to allow them in the URL
    # can by pass if we use token as a query param
    get "token/:token", to: "tokens#show", as: :token, token: /[^\/]+/

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
