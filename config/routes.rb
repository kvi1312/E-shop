Rails.application.routes.draw do
  namespace :admin do
    resources :orders
    resources :products do
      resources :stocks
    end
    resources :categories
  end
  devise_for :admins
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  root to: "home#index"

  authenticated :admin do
    root to: "admin#index", as: :admin_root
  end

  #  unauthenticated do
  #   as :user do
  #           root to: "devise/registrations#new"2
  #         end
  #  end

  resources :categories, only: [ :show ]
  resources :products, only: [ :show ]

  get "admin" => "admin#index" # config route with <controller>#page
  get "category" => "category#index"
  get "cart" => "cart#show"
  post "checkout" => "checkouts#create"
  get "success" => "checkouts#success"
  get "cancel" => "checkouts#cancel"
end
