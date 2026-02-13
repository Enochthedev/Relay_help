# frozen_string_literal: true

# Cleans up expired refresh tokens
# Scheduled to run daily
class RefreshTokenCleanupJob < ApplicationJob
  queue_as :default

  def perform
    # Delete tokens that expired more than 7 days ago
    cutoff = 7.days.ago
    expired_count = RefreshToken.where('expires_at < ?', cutoff).delete_all
    revoked_count = RefreshToken.where('revoked_at < ?', cutoff).delete_all
    
    Rails.logger.info "[RefreshTokenCleanupJob] Cleaned up #{expired_count} expired and #{revoked_count} revoked tokens"
  end
end
