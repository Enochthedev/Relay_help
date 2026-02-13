# frozen_string_literal: true

# Sends webhooks to the Discord bot service
# The bot runs separately and creates/updates Discord threads
class DiscordWebhookService
  class WebhookError < StandardError; end

  BOT_URL = ENV.fetch('DISCORD_BOT_URL', 'http://localhost:3002')

  class << self
    def notify_ticket_created(ticket_id:, ticket_number:, customer_email:, customer_name:, message:, workspace_id:)
      workspace = Workspace.find(workspace_id)
      guild = workspace.discord_guild

      return unless guild  # No Discord connected

      post('/webhook/ticket_created', {
        ticket_id: ticket_id,
        ticket_number: ticket_number,
        customer_email: customer_email,
        customer_name: customer_name,
        message: message,
        guild_id: guild.guild_id,
        support_channel_id: guild.support_channel_id,
        workspace_slug: workspace.slug
      })
    end

    def notify_ticket_updated(ticket_id:, status:, assigned_to:)
      ticket = Ticket.find(ticket_id)
      return unless ticket.discord_thread_id

      post('/webhook/ticket_updated', {
        ticket_id: ticket_id,
        discord_thread_id: ticket.discord_thread_id,
        status: status,
        assigned_to_name: assigned_to
      })
    end

    def notify_ticket_closed(ticket_id:, discord_thread_id:)
      return unless discord_thread_id

      post('/webhook/ticket_closed', {
        ticket_id: ticket_id,
        discord_thread_id: discord_thread_id
      })
    end

    def send_customer_message(ticket_id:, discord_thread_id:, message:, customer_name:)
      return unless discord_thread_id

      post('/webhook/message_from_customer', {
        ticket_id: ticket_id,
        discord_thread_id: discord_thread_id,
        message: message,
        customer_name: customer_name || 'Customer'
      })
    end

    private

    def post(path, payload)
      uri = URI("#{BOT_URL}#{path}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{ENV['DISCORD_BOT_WEBHOOK_SECRET']}"
      request.body = payload.to_json

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise WebhookError, "Discord bot webhook failed: #{response.code} - #{response.body}"
      end

      JSON.parse(response.body) rescue {}
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise WebhookError, "Discord bot webhook timeout: #{e.message}"
    rescue Errno::ECONNREFUSED => e
      Rails.logger.warn "[DiscordWebhookService] Bot not available: #{e.message}"
      # Don't raise - bot might be temporarily unavailable
      nil
    end
  end
end
