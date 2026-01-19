require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  get 'pages/home'
  # Sidekiq admin (will secure later)
  mount Sidekiq::Web => "/sidekiq"
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Root
  root "pages#home"
end