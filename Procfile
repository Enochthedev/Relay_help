# Production Procfile for Railway
# web: Main Rails server
# worker: Solid Queue background jobs

web: bundle exec puma -C config/puma.rb
worker: bundle exec rails solid_queue:start
release: bundle exec rails db:migrate
