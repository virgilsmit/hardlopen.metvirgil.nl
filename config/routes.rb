Rails.application.routes.draw do
    get 'home/index'
    resources :photos
    resources :training_drills
    resources :drills
    resources :training_routes
    resources :routes
    resources :vacations
    resources :performances
    resources :attendances
    resources :trainings
    resources :clients
    resources :groups
    resources :users
  
    get "up" => "rails/health#show", as: :rails_health_check
  
    root "photos#index"
  end