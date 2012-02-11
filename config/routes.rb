Koi::Engine.routes.draw do
  devise_for :admins, {
    :class_name => "Koi::Admin",
    module: :devise
  }

  match 'dashboard' => 'application#index', :as => :dashboard
  root to: 'application#login'
end
