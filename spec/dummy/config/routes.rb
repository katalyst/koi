Rails.application.routes.draw do

  resources :products

  constraints :subdomain => "mobile" do
    scope :module => "mobile", :as => "mobile" do
      resources :pages
      root to: "application#index"
    end
  end

  devise_for :users

  resources :categories do
    resources :products, except: [:new, :create, :edit, :update, :destroy]
  end

  resources :users, path: :members
  resources :pages, as: :koi_pages
  resources :assets, as: :koi_assets
  resources :images
  resources :documents
  resources :news_items
  resources :super_heros
  resources :kid_heros

  namespace :admin do
    resources :users, path: :members
    resources :super_heros do
      collection {
        get 'name_search'
        get 'search_id'
        get 'content_id'
        get 'search_association'
        get 'content_association'
      }
    end
    resources :kid_heros
    resources :news_items
    resources :product_images
    resources :categories do
      collection { put 'sort' }
      resources :products do
        collection { put 'sort' }
      end
    end
  end

  root to: "news_items#index"

  mount Koi::Engine => "/admin", as: "koi_engine"

  get '/:id' => 'pages#show', as: :page
end
