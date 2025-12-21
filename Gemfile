source "https://rubygems.org"
ruby "3.3.0"

gem "rails", "~> 7.1.5"
gem "bootsnap", require: false
gem "pg", "~> 1.5"
gem "puma", "~> 6.0"
gem "redis", "~> 5.0"
gem "connection_pool", "~> 2.5" # Avoid 3.0.x syntax error with Ruby 3.3.0
gem "sidekiq", "~> 7.0"

# Frontend
gem "propshaft"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "importmap-rails"

# Auth
gem "devise"

# Environment variables are injected by Phase CLI (phase run bin/dev)

# Background jobs
gem "sidekiq-scheduler"

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