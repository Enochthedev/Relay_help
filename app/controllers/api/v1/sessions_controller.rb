# frozen_string_literal: true

# Custom sessions controller for JWT authentication
# Doesn't inherit from Devise to avoid Warden middleware conflicts
class Api::V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  # POST /api/v1/login
  def create
    user = User.find_by(email: params.dig(:user, :email)&.downcase)

    if user&.valid_password?(params.dig(:user, :password))
      # Check if user can login (has password set - owners only)
      unless user.can_login?
        return render json: {
          status: { code: 403, message: 'This account cannot login via web. Use Discord instead.' }
        }, status: :forbidden
      end

      # Generate tokens
      tokens = generate_tokens(user)

      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: UserSerializer.new(user).serializable_hash[:data][:attributes],
        **tokens
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: 'Invalid email or password.' }
      }, status: :unauthorized
    end
  end

  # POST /api/v1/refresh
  def refresh
    refresh_token_value = params[:refresh_token]
    
    if refresh_token_value.blank?
      return render json: {
        status: { code: 400, message: 'Refresh token is required.' }
      }, status: :bad_request
    end

    refresh_token = RefreshToken.find_by_token(refresh_token_value)

    if refresh_token&.valid_token?
      user = refresh_token.user
      
      # Revoke old refresh token (rotation for security)
      refresh_token.revoke!
      
      # Generate new tokens
      tokens = generate_tokens(user)

      render json: {
        status: { code: 200, message: 'Token refreshed successfully.' },
        data: UserSerializer.new(user).serializable_hash[:data][:attributes],
        **tokens
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: 'Invalid or expired refresh token.' }
      }, status: :unauthorized
    end
  end

  # DELETE /api/v1/logout
  def destroy
    auth_header = request.headers['Authorization']
    refresh_token_value = params[:refresh_token]
    
    # Revoke access token if provided
    if auth_header&.start_with?('Bearer ')
      token = auth_header.split(' ').last
      
      begin
        payload = Warden::JWTAuth::TokenDecoder.new.call(token)
        JwtDenylist.create!(
          jti: payload['jti'],
          exp: Time.at(payload['exp'])
        )
      rescue JWT::DecodeError
        # Token invalid, ignore
      end
    end
    
    # Revoke refresh token if provided
    if refresh_token_value.present?
      refresh_token = RefreshToken.find_by_token(refresh_token_value)
      refresh_token&.revoke!
    end

    render json: {
      status: 200,
      message: 'Logged out successfully.'
    }, status: :ok
  end

  # DELETE /api/v1/logout_all
  def destroy_all
    # This endpoint requires authentication
    auth_header = request.headers['Authorization']
    
    unless auth_header&.start_with?('Bearer ')
      return render json: {
        status: { code: 401, message: 'Authorization required.' }
      }, status: :unauthorized
    end
    
    begin
      token = auth_header.split(' ').last
      payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      user = User.find(payload['sub'])
      
      # Revoke all refresh tokens for this user
      RefreshToken.revoke_all_for_user(user)
      
      # Revoke current access token
      JwtDenylist.create!(
        jti: payload['jti'],
        exp: Time.at(payload['exp'])
      )

      render json: {
        status: 200,
        message: 'Logged out from all devices successfully.'
      }, status: :ok
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: {
        status: { code: 401, message: 'Invalid token.' }
      }, status: :unauthorized
    end
  end

  private

  def generate_tokens(user)
    # Generate short-lived access token (JWT)
    access_token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    
    # Generate long-lived refresh token
    refresh_token = RefreshToken.generate_for(user, request: request)
    
    # Update sign in tracking
    user.update_tracked_fields!(request)
    user.save!

    # Set access token in header
    response.set_header('Authorization', "Bearer #{access_token}")

    {
      access_token: access_token,
      refresh_token: refresh_token.token,
      expires_in: ENV.fetch('JWT_EXPIRATION_HOURS', 24).to_i * 3600,
      refresh_expires_in: ENV.fetch('REFRESH_TOKEN_EXPIRY_DAYS', 7).to_i * 86400
    }
  end
end
