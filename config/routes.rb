Rails.application.routes.draw do
  # Health check
  get '/health', to: 'health#show'
  get "up" => "rails/health#show", as: :rails_health_check

  # Solid Queue admin UI (replaces Sidekiq)
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # API routes
  namespace :api do
    namespace :v1 do
      # ============ Authentication ============
      post 'login', to: 'sessions#create'
      post 'refresh', to: 'sessions#refresh'
      delete 'logout', to: 'sessions#destroy'
      delete 'logout_all', to: 'sessions#destroy_all'
      post 'signup', to: 'registrations#create'

      # User Profile
      get 'me', to: 'users#me'
      post 'workspaces/:id/switch', to: 'users#switch_workspace'

      # ============ Platform Admin ============
      get 'admin/workspaces', to: 'users#index_workspaces'

      # ============ Widget API ============
      namespace :widget do
        post 'init', to: 'widget#init'
        post 'tickets', to: 'widget#create_ticket'
        get 'tickets/:id', to: 'widget#show_ticket'
        post 'tickets/:id/messages', to: 'widget#create_message'
        post 'identify', to: 'widget#identify'
        get 'stream', to: 'stream#show'  # SSE endpoint
      end

      # ============ Webhooks (from Discord bot) ============
      namespace :webhooks do
        post 'discord/message_created', to: 'discord#message_created'
        post 'discord/thread_created', to: 'discord#thread_created'
        post 'discord/typing', to: 'discord#typing'
        post 'discord/ticket_closed', to: 'discord#ticket_closed'
      end

      # ============ Protected routes (Workspace owners) ============
      # resources :workspaces, only: [:show, :update]
      # resources :tickets, only: [:index, :show, :create, :update]
      # resources :team, only: [:index, :create, :destroy]
      
      resources :widget_keys, only: [:index, :create, :destroy]
    end
  end

  # Legacy devise routes (Web dashboard login)
  devise_for :users

  # Pages
  get 'pages/home'
  root "pages#home"
end