Rails.application.routes.draw do

  resources :users do
    member do
      
    end
    collection do
      get "forgot_password"
    end
  end
  
  resources :sessions, path_names: {new: "login", destroy: "logout"},
                       only: [:new, :create, :destroy]
                       
  resources :buildings do
    resources :building_expenses do
      member do
        get "download_attachment"
        get "delete_attachment"
      end
    end
    member do
      get "apartments"
    end
    collection do
      post "set_workspace"
    end
  end
  
  resources :bollo_ranges, :path => "bollos", :controller => "bollos" do
    member do
      get "edit_bollo"
      post "update_bollo"
      delete "destroy_bollo"
    end
  end
  
  resources :apartments do
    resources :apartment_expenses, :except => [:index] do
      member do
        get "download_attachment"
        get "delete_attachment"
      end
    end
    member do
      get "tenants"
    end
  end
  
  post "invoices" => "invoices#index"
  
  resources :invoices do
    member do
      get "approve"
      get "download"
    end
    collection do
      post "generate"
    end
  end
  
  resources :expenses
  resources :repartition_tables
  resources :contracts
  resources :balance_dates
  resources :companies, :only => [:edit, :update]
  resources :events do
    member do
      get "clear"
      get "reinstate"
    end
  end
      
  
  resources :leases do
    resources :tenants, :except => [:index]
    member do
      get "registration"
      get "download_attachment"
      get "lease_attachment"
      get "close"
      get "history"
      post "history"
      get "delete_attachment"
      get "tenant"
    end
  end
  
  resources :setup, path_names: {edit: "setup"}, only: [:edit, :update]
                       
  root "home#index"
  get "apartment_expenses" => "apartment_expenses#index", as: :apartment_expenses
  
  get "/auth/:provider/callback" => "google_sessions#create"
  get "test" => "google_sessions#new"
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
