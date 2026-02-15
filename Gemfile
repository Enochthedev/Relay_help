source "https://rubygems.org"
ruby "3.3.0"

gem "rails", "~> 7.1.5"
gem "bootsnap", require: false
gem "pg", "~> 1.5"
gem "puma", "~> 6.0"

# Frontend
gem "propshaft"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "importmap-rails"


# Auth
gem "devise"
gem 'devise-jwt'
gem 'omniauth'
gem 'omniauth-discord'
gem 'omniauth-google-oauth2'
# gem 'omniauth-apple'
gem 'omniauth-rails_csrf_protection'

# Error tracking
gem 'sentry-ruby'
gem 'sentry-rails'

# Structured logging
gem 'lograge'

# Performance monitoring (optional for MVP, but recommended)
gem 'appsignal'

# API
gem 'rack-cors'
gem 'rack-attack'
gem 'jsonapi-serializer'

# Background jobs - PostgreSQL-based (no Redis needed!)
gem "solid_queue"
gem "mission_control-jobs"  # Admin UI for jobs

# Environment variables are injected by Phase CLI (phase run bin/dev)

group :development, :test do
  gem "debug"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "annotate"
  gem "web-console"
end