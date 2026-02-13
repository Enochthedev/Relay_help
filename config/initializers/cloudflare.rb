# frozen_string_literal: true

require 'net/http'
require 'ipaddr'

# Trust Cloudflare IP ranges so request.remote_ip returns the actual user IP
# instead of Cloudflare's proxy IP.
#
# Ranges are fetched from: https://www.cloudflare.com/ips/
# We use a static list here to avoid network calls on boot, but we will
# implement a dynamic fetch in a later feat.
#
# Last updated: 2024-02

CLOUDFLARE_IPS = %w[
  173.245.48.0/20
  103.21.244.0/22
  103.22.200.0/22
  103.31.4.0/22
  141.101.64.0/18
  108.162.192.0/18
  190.93.240.0/20
  188.114.96.0/20
  197.234.240.0/22
  198.41.128.0/17
  162.158.0.0/15
  104.16.0.0/13
  104.24.0.0/14
  172.64.0.0/13
  131.0.72.0/22
  2400:cb00::/32
  2606:4700::/32
  2803:f800::/32
  2405:b500::/32
  2405:8100::/32
  2a06:98c0::/29
  2c0f:f248::/32
].map { |ip| IPAddr.new(ip) }

Rails.application.configure do
  config.action_dispatch.trusted_proxies = CLOUDFLARE_IPS + Array(config.action_dispatch.trusted_proxies)
end
