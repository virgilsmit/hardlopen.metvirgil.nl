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
    delete :remove_member, on: :member
  end
  resources :users
  resources :lopers, controller: 'users'
  resources :import_history, only: [:index]
  get 'training_sessions/vandaag', to: 'training_sessions#vandaag', as: :vandaag_training_session
  get '/training_sessions/preview_cores', to: 'training_sessions#preview_cores', as: :preview_cores_training_sessions
  get '/training_sessions/preview_upcoming_cores', to: 'training_sessions#preview_upcoming_cores', as: :preview_upcoming_cores_training_sessions
  get '/training_sessions/preview_all_cores', to: 'training_sessions#preview_all_cores', as: :preview_all_cores_training_sessions
  resources :training_sessions, only: [:show, :edit, :update] do
    member do
      get  :log_attendance, to: 'training_results#new_bulk'
      post :log_attendance, to: 'training_results#create_bulk'
    end
  end
  get 'mijntrainingen', to: 'training_sessions#mijn', as: :mijn_trainingen
  get 'training_sessions/:id/data', to: 'training_sessions#data', as: :training_session_data
  get 'training_sessions/:id/preview_core', to: 'training_sessions#preview_structured_core', as: :preview_core_training_session
  patch '/training_sessions/:id/core', to: 'training_sessions#update_core', as: :update_core_training_session

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
  post 'import/trainings', to: 'imports#import_trainings_via_form', as: :import_trainings_imports

  get 'home/demo', to: 'home#demo'

  get 'trainers/tijden', to: 'trainers#tijden', as: :trainers_tijden

  get 'trainers', to: 'trainers#index', as: :trainers

  get 'trainers/verjaardagen', to: 'trainers#verjaardagen', as: :trainers_verjaardagen

  get 'trainers/beheer', to: 'trainers#beheer', as: :trainers_beheer

  post 'trainers/promote_trainer', to: 'trainers#promote_trainer', as: :promote_trainer_trainers

  get 'trainers/overzicht', to: 'trainers#overzicht', as: :trainers_overzicht

  get 'trainers/ad_gemiddelden', to: 'trainers#ad_gemiddelden', as: :trainers_ad_gemiddelden

  namespace :admin do
    resources :users, only: [:index] do
      member do
        patch :update_role
      end
    end
    resources :tiles, only: [:index] do
      collection do
        patch :update
        put :update
        patch :update_label
        put :update_label
        patch :update_order
        put :update_order
        post :save_all
      end
    end
    get '/', to: 'dashboard#index', as: :dashboard
    get 'schemas/koppelen', to: 'schemas#koppelen', as: :schemas_koppelen
    post 'schemas/koppelen', to: 'schemas#koppelen'
    post 'schemas/rename', to: 'schemas#rename', as: :schemas_rename
  end

  get '/schema', to: 'training_schemas#index', as: :schema
  get '/schema/volledig', to: 'training_schemas#show', as: :schema_volledig
  get '/schema/week', to: 'training_schemas#show', defaults: { week: 'current' }, as: :schema_week
  get '/schema/alle', to: 'training_schemas#all', as: :schema_all
  get '/schema/dezeweek', to: 'training_schemas#dezeweek', as: :schema_dezeweek

  patch 'profile/training_days', to: 'users#update_training_days', as: :update_training_days

  get '/afmelden/:slug/:token', to: 'public_runners#afmelden', as: :public_afmelden
  post '/afmelden/:slug/:token', to: 'public_runners#afmelden'

  # Logging actual training results
  get 'training_sessions/:id/log', to: 'training_results#new', as: :log_training_session
  resources :training_results, only: [:create, :edit, :update]

  root "home#index"
end
