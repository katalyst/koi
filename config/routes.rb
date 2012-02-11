Koi::Engine.routes.draw do
  devise_for :admins, {
    class_name: "Koi::Admin",
    module: :devise
  }

  get "application/login"

  root to: "application#index"
end
