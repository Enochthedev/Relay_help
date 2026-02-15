Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'identify email'
  
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'openid,email,profile',
    prompt: 'select_account',
    image_aspect_ratio: 'square',
    image_size: 50
  }
  
  # provider :apple, ENV['APPLE_CLIENT_ID'], '', {
  #   scope: 'email name',
  #   team_id: ENV['APPLE_TEAM_ID'],
  #   key_id: ENV['APPLE_KEY_ID'],
  #   pem: ENV['APPLE_PRIVATE_KEY']&.gsub("\\n", "\n") # Handle newlines in env var
  # }
end

# Allow GET requests for OAuth initiation (needed for simple window.location.href redirects)
OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
