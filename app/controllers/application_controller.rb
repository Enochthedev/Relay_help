class ApplicationController < ActionController::Base
  include ErrorHandling

  # Skip CSRF for API requests - we use JWT tokens instead
  # CSRF is for cookie-based browser sessions, not needed for stateless API auth
  skip_before_action :verify_authenticity_token
end
