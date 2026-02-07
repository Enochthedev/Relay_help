# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true

  # Use JSON format for structured logging
  config.lograge.formatter = Lograge::Formatters::Json.new

  # Include additional useful info
  config.lograge.custom_options = lambda do |event|
    {
      time: Time.current.iso8601,
      request_id: event.payload[:request_id],
      user_id: event.payload[:user_id],
      remote_ip: event.payload[:remote_ip],
      user_agent: event.payload[:user_agent]
    }.compact
  end

  # Include params (excluding sensitive ones)
  config.lograge.custom_payload do |controller|
    {
      request_id: controller.request.request_id,
      user_id: controller.current_user&.id,
      remote_ip: controller.request.remote_ip,
      user_agent: controller.request.user_agent
    }
  end
end
