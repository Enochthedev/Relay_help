module Api
  module V1
    class AuthController < ApplicationController

      
      # GET /api/v1/auth/:provider
      def redirect
        provider = params[:provider]
        
        # Map frontend provider names to OmniAuth provider names
        provider_map = {
          'google' => 'google_oauth2',
          'discord' => 'discord'
        }
        
        omniauth_provider = provider_map[provider]
        
        # Validate provider to prevent open redirect/abuse
        unless omniauth_provider
          return render json: { error: "Invalid provider" }, status: :bad_request
        end
        
        # The frontend URL to redirect back to after success
        # We can store this in the session or state param if needed, 
        # but for now we'll hardcode the callback to the frontend's auth page
        
        redirect_to "/auth/#{omniauth_provider}"
      end
      
      # GET /api/v1/auth/:provider/callback
      def callback
        auth = request.env['omniauth.auth']

        if auth.nil?
          # If auth is nil, something went wrong with OmniAuth
          frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:3000')
          return redirect_to "#{frontend_url}/auth/login?error=Authentication failed", allow_other_host: true
        end
        
        # Find or create user from omniauth data
        @user = User.from_omniauth(auth)
        
        if @user.persisted?
          # Generate JWT tokens
          token = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil).first
          
          # Create a refresh token
          refresh_token_record = RefreshToken.generate_for(@user, request: request)
          refresh_token_string = refresh_token_record.token
          
          # Redirect to frontend with tokens
          frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:3000')
          
          redirect_to "#{frontend_url}/auth/callback?accessToken=#{token}&refreshToken=#{refresh_token_string}&expiresIn=86400&refreshExpiresIn=604800", allow_other_host: true
        else
          # Redirect to login with error
          frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:3000')
          redirect_to "#{frontend_url}/auth/login?error=Could not sign in with #{params[:provider].titleize}", allow_other_host: true
        end
      rescue StandardError => e
        # Log error
        Rails.logger.error("Auth Error: #{e.message}")
        frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:3000')
        redirect_to "#{frontend_url}/auth/login?error=Authentication failed", allow_other_host: true
      end
      
      private
      
      def generate_refresh_token(user)
        # Create a refresh token record
        # You might have a RefreshToken model or similar
        # For now, simplistic implementation based on existing auth patterns
        
        # If using devise-jwt, it might handle refresh tokens differently
        # But per the user request, we need to return a refresh token string
        
        # Let's create a refresh token record manually if the model exists
        if defined?(RefreshToken)
           token = SecureRandom.hex(32)
           RefreshToken.create!(
             user: user,
             token_digest: token, # Assuming this is how it's stored, or hash it
             expires_at: 7.days.from_now
           )
           return token
        else
           # Fallback if no specific refresh token logic is exposed easily
           # But the user request implies we output one. 
           # Let's assume we can generate a simple one for now or look at SessionsController
           SecureRandom.hex(32) 
        end
      end
    end
  end
end
