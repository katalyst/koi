Koi::Engine.routes.draw do
  devise_for :admins, :class_name => "Koi::Admin"

  root to: "application#index"
end
