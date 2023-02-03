# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :articles, only: %i[index show new create edit update destroy]
  end

  resources :articles, only: %i[index show] do
    get "preview", on: :member
  end

  root to: "articles#index"

  mount Koi::Engine => "/admin", as: "koi_engine"
end
