# frozen_string_literal: true

# Broadcasts updates to connected widgets via PostgreSQL NOTIFY
# This is used when an agent responds in Discord and we need to push to the widget
class WidgetBroadcastService
  class << self
    # Broadcast a new message to all connected widget sessions for a ticket
    def broadcast_message(message:)
      ticket = message.ticket
      customer = ticket.customer
      
      # Find all active widget sessions for this customer
      sessions = customer.widget_sessions.active

      return if sessions.empty?

      payload = {
        type: 'new_message',
        ticket_id: ticket.id,
        message: {
          id: message.id,
          body: message.body,
          message_type: message.message_type,
          created_at: message.created_at.iso8601,
          from: message.user_id ? 'agent' : 'customer',
          agent_name: message.user&.name
        }
      }

      # Notify each connected session
      sessions.find_each do |session|
        notify_session(session.id, payload)
      end
    end

    # Broadcast ticket status update
    def broadcast_ticket_update(ticket:, changes: {})
      customer = ticket.customer
      sessions = customer.widget_sessions.active

      return if sessions.empty?

      payload = {
        type: 'ticket_updated',
        ticket_id: ticket.id,
        ticket_number: ticket.ticket_number,
        status: ticket.status,
        changes: changes
      }

      sessions.find_each do |session|
        notify_session(session.id, payload)
      end
    end

    # Broadcast typing indicator
    def broadcast_typing(ticket:, agent_name:)
      customer = ticket.customer
      sessions = customer.widget_sessions.active

      return if sessions.empty?

      payload = {
        type: 'typing',
        ticket_id: ticket.id,
        agent_name: agent_name
      }

      sessions.find_each do |session|
        notify_session(session.id, payload)
      end
    end

    private

    def notify_session(session_id, payload)
      channel = "widget_updates_#{session_id}"
      
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.sanitize_sql([
          "SELECT pg_notify(?, ?)",
          channel,
          payload.to_json
        ])
      )
    rescue => e
      Rails.logger.error "[WidgetBroadcastService] Failed to notify: #{e.message}"
    end
  end
end
