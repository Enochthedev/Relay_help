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
      patch 'me', to: 'users#update'
      post 'workspaces/:id/switch', to: 'users#switch_workspace'
      
      # Social Auth
      get 'auth/:provider', to: 'auth#redirect'
      get 'auth/:provider/callback', to: 'auth#callback'

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
      # ============ Protected routes (Workspace owners) ============
      
      # Singular resource for current context
      resource :workspace, only: [:show, :update, :destroy], controller: 'workspaces' do
        collection do
          get '', to: 'workspaces#show_current'
          patch '', to: 'workspaces#update_current'
          delete '', to: 'workspaces#destroy_current'
        end
      end

      # Standard CRUD resources
      resources :workspaces, only: [:index, :show, :create, :update, :destroy]

      # resources :tickets, only: [:index, :show, :create, :update]
      # resources :team, only: [:index, :create, :destroy]
      
      resources :widget_keys, only: [:index, :create, :destroy]
    end
  end

  # Legacy devise routes (Web dashboard login)
  devise_for :users

  # OmniAuth Callbacks (Must be at root level because OmniAuth defaults to /auth/:provider/callback)
  get '/auth/:provider/callback', to: 'api/v1/auth#callback'

  # Pages
  get 'pages/home'
  root "pages#home"
end