module ErrorHandling
  extend ActiveSupport::Concern
  
  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  end
  
  private
  
  def handle_standard_error(exception)
    Sentry.capture_exception(exception)
    Rails.logger.error("Unhandled error: #{exception.message}")
    
    render json: { 
      error: 'Something went wrong',
      message: exception.message 
    }, status: :internal_server_error
  end
  
  def handle_not_found(exception)
    render json: { 
      error: 'Not found',
      message: exception.message 
    }, status: :not_found
  end
  
  def handle_bad_request(exception)
    render json: { 
      error: 'Bad request',
      message: exception.message 
    }, status: :bad_request
  end
end