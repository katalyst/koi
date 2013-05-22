Koi::Engine.routes.draw do
  devise_for :admins,
             :class_name => "Admin",
             controllers: { passwords: "Koi::Passwords" },
             module: "Devise"

  resources :assets do
    get 'index', on: :collection, to: 'assets#new'
    member do
      get 'delete'
      delete 'delete', to: 'assets#destroy'
    end
  end
  resources :images do
    get 'index', on: :collection, to: 'images#new'
    member do
      get 'delete'
      delete 'delete', to: 'images#destroy'
    end
  end
  resources :documents do
    get 'index', on: :collection, to: 'documents#new'
    member do
      get 'delete'
      delete 'delete', to: 'documents#destroy'
    end
  end

  resources :translations, path: :site_settings do
    get :seed, on: :collection
  end
  resources :settings
  resources :pages
  resources :admins, path: :site_users
  resources :module_nav_items
  resources :folder_nav_items
  resources :alias_nav_items
  resources :resource_nav_items
  resources :nav_items do
    get :toggle, on: :member
    collection do
      get :sitemap
      post :savesort
    end
  end
  match 'help' => 'application#help', :as => :help
  match 'dashboard' => 'application#index', :as => :dashboard
  root to: 'application#login'

  constraint = lambda { |request| request.env["warden"].authenticate? && request.env['warden'].user.respond_to?(:god?) && request.env['warden'].user.god? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq', as: :sidekiq
  end
end
