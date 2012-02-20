Koi::Engine.routes.draw do
  devise_for :admins, {
    class_name: 'Admin',
    module: :devise
  }

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

  resources :translations, path: :site_settings
  resources :settings
  resources :pages
  resources :admins
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
  match 'dashboard' => 'application#index', :as => :dashboard
  root to: 'application#login'
end
