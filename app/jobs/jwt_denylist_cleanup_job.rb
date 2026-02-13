# frozen_string_literal: true

# Cleans up expired JWT tokens from the denylist
# Scheduled to run daily
class JwtDenylistCleanupJob < ApplicationJob
  queue_as :default

  def perform
    expired_count = JwtDenylist.where('exp < ?', Time.current).delete_all
    Rails.logger.info "[JwtDenylistCleanupJob] Cleaned up #{expired_count} expired tokens"
  end
end
