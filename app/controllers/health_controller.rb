class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  def show
     checks = {
      database: check_database,
      timestamp: Time.current.iso8601
    }
    
    if checks[:database][:healthy]
      render json: { status: 'ok', checks: checks }, status: :ok
    else
      render json: { status: 'unhealthy', checks: checks }, status: :service_unavailable
    end
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
    Sentry.capture_exception(e)
    { 
      healthy: false, 
      error: e.message 
    }
  end
end
