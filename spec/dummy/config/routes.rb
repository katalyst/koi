# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
  end

  mount Koi::Engine => "/admin", as: "koi_engine"
end
