Rails.application.routes.draw do
  get 'training_schemas/index'
  get 'training_schemas/show'
  resources :training_schemas, only: [:update]
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
  
  resources :events do
    collection do
      get :import
      post :do_import
      post :do_import_loopjes_2026
    end
  end
  
  resources :attendances
  resources :trainings do
    resources :attendances, only: [:create, :update]
  end
  resources :clients
  resources :groups do
    post :add_members, on: :member
    delete :remove_member, on: :member
  end
  resources :users do
    member do
      get :zones
    end
  end
  resources :lopers, controller: 'users' do
    member do
      get :zones
    end
  end
  resources :import_history, only: [:index]
  get 'training_sessions/vandaag', to: 'training_sessions#vandaag', as: :vandaag_training_session
  get 'training_sessions/vandaag/quick_attendance', to: 'training_sessions#vandaag_quick_attendance', as: :vandaag_quick_attendance
  get '/training_sessions/preview_cores', to: 'training_sessions#preview_cores', as: :preview_cores_training_sessions
  get '/training_sessions/preview_upcoming_cores', to: 'training_sessions#preview_upcoming_cores', as: :preview_upcoming_cores_training_sessions
  get '/training_sessions/preview_all_cores', to: 'training_sessions#preview_all_cores', as: :preview_all_cores_training_sessions
  # Test routes
  get '/test/redirect', to: 'test#redirect_test'
  get '/test/blank', to: 'test#blank_test'
  
  resources :training_sessions, only: [:show, :edit, :update] do
    member do
      get  :log_attendance, to: 'training_results#new_bulk'
      post :log_attendance, to: 'training_results#create_bulk'
      get  :quick_attendance
      post :finalize_attendance, action: :finalize_attendance
    end
  end
  get 'mijntrainingen', to: 'training_sessions#mijn', as: :mijn_trainingen
  get 'training_sessions/:id/data', to: 'training_sessions#data', as: :training_session_data
  get 'training_sessions/:id/preview_core', to: 'training_sessions#preview_structured_core', as: :preview_core_training_session
  patch '/training_sessions/:id/core', to: 'training_sessions#update_core', as: :update_core_training_session
  
  # API endpoints for iOS app
  get 'api/training_sessions/today', to: 'training_sessions#api_today', as: :api_training_sessions_today
  get 'api/training_sessions/week', to: 'training_sessions#api_week', as: :api_training_sessions_week
  get 'api/training_sessions/upcoming', to: 'training_sessions#api_upcoming', as: :api_training_sessions_upcoming
  get 'api/training_sessions/schedule', to: 'training_sessions#api_schedule', as: :api_training_sessions_schedule

  delete 'logout', to: 'sessions#destroy', as: :logout
  get "up" => "rails/health#show", as: :rails_health_check

  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'

  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :intakes, only: [:new, :create]
  get 'intake', to: 'intakes#new', as: :intake

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
    resources :login_logs, only: [:index]
    resources :error_logs, only: [:index, :show, :destroy] do
      member do
        post :resolve
        post :reopen
        patch :update_notes
      end
      collection do
        post :bulk_resolve
        post :bulk_delete
        delete :clear_resolved
      end
    end
    resources :error_messages, only: [:index, :edit, :update]
    resources :intakes, only: [:index, :show] do
      post :convert, on: :member
    end
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
    resources :themes do
      member do
        patch :activate
        put :activate
      end
    end
    get '/', to: 'dashboard#index', as: :dashboard
    get 'schemas/koppelen', to: 'schemas#koppelen', as: :schemas_koppelen
    post 'schemas/koppelen', to: 'schemas#koppelen'
    post 'schemas/rename', to: 'schemas#rename', as: :schemas_rename
  end
  
  resources :site_contents, only: [:index] do
    collection do
      patch :update
      put :update
      post :create_button
    end
  end
  
  # Hero button routes
  patch 'site_contents/:id/update_button', to: 'site_contents#update_button', as: :update_button_site_content
  delete 'site_contents/:id/destroy_button', to: 'site_contents#destroy_button', as: :destroy_button_site_content

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

  get '/verjaardagen/komende', to: 'birthdays#index', as: :upcoming_birthdays

  get 'prototype', to: 'home#prototype', as: :prototype
  get 'prototype-info', to: 'home#prototype_info', as: :prototype_info
  get 'prototype-track', to: 'home#prototype_track', as: :prototype_track
  get 'sport', to: 'home#sport_index', as: :sport_home

  root "home#sport_index"
  
  # Test endpoint (temporary - remove after debugging)
  get '/test/error_logs', to: 'test#error_logs_test'
  get '/test/error_logs_fresh', to: 'test#error_logs_test'
end
