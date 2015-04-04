Rails.application.routes.draw do

  resources :users do
    collection do
      get "forgot_password"
      post "forgot_password"
      get "contract"
      get "invoices"
      get "mavs"
      get "profile"
      post "profile"
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
  
  resources :invoices do
    member do
      get "approve"
      get "download"
    end
    collection do
      post "generate"
    end
  end
  
  resources :expenses do
    member do
      get "check_balance_date"
    end
  end
  
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
  
  resources :ads do
    member do
      get "approve"
    end
    collection do
      get "approve_all"
      get "administration"
      get "personal_ads"
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
      get "confirm"
    end
  end
  
  resources :unpaid_emails do
    collection do
      get "send_unpaid_emails"
    end
  end
  resources :unpaid_alarms do
    collection do
      get "set_unpaid_alarms"
    end
  end
  resources :unpaid_warnings do
    collection do
      get "default_warning"
      post "default_warning"
    end
  end
  
  resources :mavs do
    collection do
      get "csvs"
      get "unpaid"
      post "report_paid"
      post "upload_batch"
    end
    member do
      get "generate_csv"
      get "download"
    end
  end
  
  resources :setup, path_names: {edit: "setup"}, only: [:edit, :update]
                       
  root "home#index"
  get "apartment_expenses" => "apartment_expenses#index", as: :apartment_expenses
  post "/mavs" => "mavs#index"
  
  get "users/reset-password/:pw_code" => "users#reset_password"
  post "users/reset-password/:pw_code" => "users#reset_password"
  get "users/activate/:activation_code" => "users#activate"
  
  
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
