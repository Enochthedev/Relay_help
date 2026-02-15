# frozen_string_literal: true

class Rack::Attack
  # Rate limit all requests to 100 requests per minute per IP
  throttle('req/ip', limit: 100, period: 1.minute) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Rate limit login attempts to 5 requests per 20 seconds per IP
  throttle('login/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/api/v1/login' && req.post?
      req.ip
    end
  end

  # Block suspicious requests
  # blocklist('fail2ban') do |req|
  #   # `filter` returns truthy value if request fails, or if it's from a banned IP
  #   Rack::Attack::Fail2Ban.filter("ban:#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 5.minutes) do
  #     # The count for the IP is incremented if the return value is truthy
  #     req.path == '/login' && req.post?
  #   end
  # end

  # Allow local requests
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    [ 429,  # status
      { 'Content-Type' => 'application/json' }, # headers
      [{ error: 'Rate limit exceeded. Try again later.' }.to_json] # body
    ]
  end
end
