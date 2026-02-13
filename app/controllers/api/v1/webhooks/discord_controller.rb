# frozen_string_literal: true

# Receives webhooks from the Discord bot
# When an agent responds in Discord, the bot calls these endpoints
class Api::V1::Webhooks::DiscordController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_webhook_secret

  # POST /api/v1/webhooks/discord/message_created
  # Called when an agent sends a message in a Discord thread
  def message_created
    ticket = Ticket.find_by(discord_thread_id: params[:discord_thread_id])
    unless ticket
      return render json: { error: 'Ticket not found' }, status: :not_found
    end

    # Find the agent by Discord ID
    agent = User.find_by(discord_user_id: params[:agent_discord_id])

    ActiveRecord::Base.transaction do
      # Create message
      message = ticket.messages.create!(
        user: agent,
        body: params[:message],
        message_type: 'agent',
        discord_message_id: params[:discord_message_id]
      )

      # Broadcast to widget immediately via SSE
      WidgetBroadcastService.broadcast_message(message: message)

      render json: { 
        message_id: message.id,
        status: 'created'
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /api/v1/webhooks/discord/thread_created
  # Called when the bot creates a Discord thread for a ticket
  def thread_created
    ticket = Ticket.find(params[:ticket_id])

    ticket.update!(discord_thread_id: params[:discord_thread_id])

    render json: { 
      ticket_id: ticket.id,
      status: 'linked'
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Ticket not found' }, status: :not_found
  end

  # POST /api/v1/webhooks/discord/typing
  # Called when an agent starts typing in Discord
  def typing
    ticket = Ticket.find_by(discord_thread_id: params[:discord_thread_id])
    return render json: { status: 'ignored' } unless ticket

    agent = User.find_by(discord_user_id: params[:agent_discord_id])
    agent_name = agent&.name || 'Support Agent'

    # Broadcast typing indicator to widget
    WidgetBroadcastService.broadcast_typing(ticket: ticket, agent_name: agent_name)

    render json: { status: 'broadcast' }
  end

  # POST /api/v1/webhooks/discord/ticket_closed
  # Called when an agent closes a ticket from Discord
  def ticket_closed
    ticket = Ticket.find_by(discord_thread_id: params[:discord_thread_id])
    return render json: { error: 'Ticket not found' }, status: :not_found unless ticket

    ticket.close!

    # Broadcast to widget
    WidgetBroadcastService.broadcast_ticket_update(
      ticket: ticket,
      changes: { status: 'closed' }
    )

    render json: { 
      ticket_id: ticket.id,
      status: 'closed'
    }
  end

  private

  def verify_webhook_secret
    expected = ENV['DISCORD_BOT_WEBHOOK_SECRET']
    provided = request.headers['Authorization']&.gsub('Bearer ', '')

    unless provided.present? && ActiveSupport::SecurityUtils.secure_compare(expected.to_s, provided.to_s)
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
