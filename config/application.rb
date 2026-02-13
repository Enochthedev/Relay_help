require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RelayHelp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    # Use UUIDs by default
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.api_only = true

    # Add session middleware for Devise (required for JWT auth flow)
    # This is minimal - just enough for Devise's sign_in helper
    config.session_store :cookie_store, key: '_relay_help_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, config.session_options

    # Add CORS support for Next.js frontend
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        # Use CORS_ORIGINS env var in production, fallback to localhost for dev
        # Set CORS_ORIGINS="https://app.example.com,https://staging.example.com" in production
        allowed_origins = ENV.fetch("CORS_ORIGINS", "http://localhost:3000,http://localhost:3001")
                            .split(",")
                            .map(&:strip)

        origins(*allowed_origins)

        resource "*",
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true,
          # Expose headers the frontend might need
          expose: %w[X-Total-Count X-Page X-Per-Page Authorization],
          # Cache preflight requests for 1 hour (reduces OPTIONS requests)
          max_age: 3600
      end
    end
    
    # Load domain folders
    config.eager_load_paths += Dir["#{config.root}/app/domains/**/"]
    
    # Autoload lib directory
    config.autoload_lib(ignore: %w(assets tasks))

    # CamelCase JSON responses for JavaScript frontend
    require_relative '../lib/middleware/camel_case_response_middleware'
    config.middleware.use CamelCaseResponseMiddleware

    # snake_case incoming JSON params from JavaScript frontend
    require_relative '../lib/middleware/snake_case_params_middleware'
    config.middleware.use SnakeCaseParamsMiddleware

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
