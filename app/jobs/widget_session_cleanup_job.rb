# frozen_string_literal: true

# Cleans up expired widget sessions
# Scheduled to run hourly
class WidgetSessionCleanupJob < ApplicationJob
  queue_as :default

  def perform
    expired_count = WidgetSession.expired.delete_all
    Rails.logger.info "[WidgetSessionCleanupJob] Cleaned up #{expired_count} expired widget sessions"
  end
end
