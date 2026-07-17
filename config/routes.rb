# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :admin_users do
      get :archived, on: :collection
      put :archive, on: :collection
      put :restore, on: :collection

      resources :tokens, only: %i[create], module: :sessions
    end

    resource :cache, only: %i[destroy]
    resource :dashboard, only: %i[show]

    resources :device_authorizations, param: :user_code, only: %i[create show update]
    resources :device_tokens, only: %i[create]

    scope :active_storage, module: :active_storage do
      post :direct_uploads, to: "direct_uploads#create"
    end

    resource :profile, only: %i[show edit update], shallow: true do
      resources :credentials, only: %i[show new create update destroy]
      resource :otp, only: %i[new create destroy]
    end

    resource :session, only: %i[new create destroy] do
      # JWT tokens contain periods
      resources :tokens, param: :token, only: %i[show update], token: /[^\/]+/, module: :sessions
    end

    resources :background_jobs, only: %i[index show], param: :active_job_id do
      collection do
        get :scheduled
        get :in_progress
        get :blocked
        get :failed
        get :completed

        post :retry_all
        delete :discard_all
      end

      member do
        post :retry
        delete :discard
      end
    end
    resources :recurring_tasks, only: %i[index show], param: :key do
      post :run, on: :member
    end
    resources :feature_flags, except: :edit, param: :key if Object.const_defined?(:Flipper)
    resources :url_rewrites
    resources :well_knowns

    root to: redirect("admin/dashboard")
  end

  scope :admin do
    mount Katalyst::Content::Engine, at: "content"
    mount Katalyst::Navigation::Engine, at: "navigation"

    # @deprecated use /admin/feature_flags instead, remove in 6.0
    mount Flipper::UI.app(Flipper) => "flipper" if Object.const_defined?("Flipper::UI")
  end

  resources :well_knowns, path: ".well-known", param: :name, only: %i[show], name: /.+/

  # Fallbacks for optional dependencies
  unless Object.const_defined?("HotwireCombobox")
    get "hotwire_combobox", to: ->(_) { [204, {}, []] }, as: nil
  end
end
