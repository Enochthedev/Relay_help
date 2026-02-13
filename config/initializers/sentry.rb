# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  # Set traces_sample_rate to capture a percentage of transactions for tracing.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", 0.1).to_f

  # Set profiles_sample_rate to profile a percentage of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = ENV.fetch("SENTRY_PROFILES_SAMPLE_RATE", 0.1).to_f

  # Enable breadcrumbs for better debugging context
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Only enable Sentry if DSN is present (include development for testing)
  config.enabled_environments = %w[development production staging] if config.dsn.present?

  # Filter sensitive parameters
  config.send_default_pii = false
end
