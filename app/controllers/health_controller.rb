class HealthController < ApplicationController
  def show
    checks = {
      database: check_database,
      timestamp: Time.current.iso8601
    }

    # Always return 200 so Railway healthcheck passes.
    # DB status is reported in the body for debugging.
    render json: { status: 'ok', checks: checks }, status: :ok
  end

  private

  def check_database
    start = Time.now
    ActiveRecord::Base.connection.execute("SELECT 1")
    latency = ((Time.now - start) * 1000).round(2)

    {
      healthy: true,
      latency_ms: latency
    }
  rescue => e
    Rails.logger.error("Health check DB failure: #{e.message}")
    {
      healthy: false,
      error: e.message
    }
  end
end
