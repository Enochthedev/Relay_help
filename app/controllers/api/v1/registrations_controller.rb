# frozen_string_literal: true

# Custom registrations controller for owner signup
class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  # POST /api/v1/signup
  def create
    ActiveRecord::Base.transaction do
      # Create workspace
      workspace = Workspace.create!(
        name: params[:workspace_name],
        slug: params[:workspace_name].to_s.parameterize
      )

      # Create user as owner
      user = User.new(sign_up_params)
      user.workspace = workspace
      # Role is now managed via WorkspaceMembership
      user.save!

      # Create membership
      user.workspace_memberships.create!(
        workspace: workspace,
        role: :owner
      )

      # Generate tokens
      tokens = generate_tokens(user)

      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: UserSerializer.new(user).serializable_hash[:data][:attributes],
        **tokens
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: {
      status: { code: 422, message: "User couldn't be created successfully. #{e.message}" }
    }, status: :unprocessable_entity
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end

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
