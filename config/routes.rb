Rails.application.routes.draw do
  get 'training_schemas/index'
  get 'training_schemas/show'
  resources :statuses
  get 'import_history/index'
  get 'home/index'
  resources :photos
  resources :training_drills
  resources :drills
  resources :training_routes
  resources :routes
  resources :vacations
  resources :performances
  resources :attendances
  resources :trainings do
    resources :attendances, only: [:create, :update]
  end
  resources :clients
  resources :groups do
    post :add_members, on: :member
  end
  resources :users
  resources :lopers, controller: 'users'
  resources :import_history, only: [:index]
  resources :training_sessions, only: [:show]

  delete 'logout', to: 'sessions#destroy', as: :logout
  get "up" => "rails/health#show", as: :rails_health_check

  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'

  get 'register', to: 'users#register', as: :register
  post 'register', to: 'users#create_registration'

  get 'profile', to: 'users#profile', as: :profile

  get 'import', to: 'imports#new', as: :import
  post 'import/preview', to: 'imports#preview', as: :import_preview
  post 'import', to: 'imports#create', as: :import_create

  get 'home/demo', to: 'home#demo'

  get 'trainers/tijden', to: 'trainers#tijden', as: :trainers_tijden

  get 'trainers', to: 'trainers#index', as: :trainers

  get 'trainers/verjaardagen', to: 'trainers#verjaardagen', as: :trainers_verjaardagen

  namespace :admin do
    resources :users, only: [:index] do
      member do
        patch :update_role
      end
    end
    get '/', to: 'dashboard#index', as: :dashboard
  end

  get '/schema', to: 'training_schemas#index', as: :schema
  get '/schema/volledig', to: 'training_schemas#show', as: :schema_volledig
  get '/schema/week', to: 'training_schemas#show', defaults: { week: 'current' }, as: :schema_week

  root "home#index"
end
