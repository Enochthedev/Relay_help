# frozen_string_literal: true

# Processes outbox events using PostgreSQL LISTEN/NOTIFY
# Runs as a background process for near-instant event delivery
#
# Usage: bin/rails runner 'OutboxProcessor.new.run'
# Or in production: bundle exec rails runner 'OutboxProcessor.new.run'
class OutboxProcessor
  CHANNEL = 'outbox_events'
  MAX_RETRIES = 5
  BATCH_SIZE = 100

  def initialize
    @running = true
    @handlers = {}
    register_handlers
  end

  # Main loop - listens for new events
  def run
    Rails.logger.info "[OutboxProcessor] Starting..."

    # Process any pending events first
    process_pending_events

    # Listen for new events
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      raw_conn = conn.raw_connection
      raw_conn.exec("LISTEN #{CHANNEL}")

      Rails.logger.info "[OutboxProcessor] Listening for events on #{CHANNEL}"

      while @running
        # Wait for notification with timeout (allows graceful shutdown)
        raw_conn.wait_for_notify(5) do |channel, pid, event_id|
          process_event_by_id(event_id)
        end

        # Also check for any pending events (in case NOTIFY was missed)
        process_pending_events
      end

      raw_conn.exec("UNLISTEN #{CHANNEL}")
    end

    Rails.logger.info "[OutboxProcessor] Stopped"
  end

  def stop
    @running = false
  end

  private

  def register_handlers
    # Register handlers for each event type
    @handlers[OutboxEvent::TICKET_CREATED] = ->(event) { handle_ticket_created(event) }
    @handlers[OutboxEvent::TICKET_UPDATED] = ->(event) { handle_ticket_updated(event) }
    @handlers[OutboxEvent::TICKET_CLOSED] = ->(event) { handle_ticket_closed(event) }
    @handlers[OutboxEvent::MESSAGE_FROM_CUSTOMER] = ->(event) { handle_message_from_customer(event) }
    @handlers[OutboxEvent::MESSAGE_FROM_AGENT] = ->(event) { handle_message_from_agent(event) }
  end

  def process_pending_events
    OutboxEvent.pending.order(:created_at).limit(BATCH_SIZE).each do |event|
      process_event(event)
    end
  end

  def process_event_by_id(event_id)
    event = OutboxEvent.find_by(id: event_id)
    return unless event&.pending?

    process_event(event)
  end

  def process_event(event)
    event.start_processing!

    handler = @handlers[event.event_type]
    if handler
      handler.call(event)
      event.complete!
      Rails.logger.info "[OutboxProcessor] Completed: #{event.event_type} (#{event.id})"
    else
      Rails.logger.warn "[OutboxProcessor] No handler for: #{event.event_type}"
      event.complete!  # Mark as complete even if no handler
    end
  rescue StandardError => e
    Rails.logger.error "[OutboxProcessor] Failed: #{event.event_type} - #{e.message}"
    event.fail!(e.message)

    # Re-raise for Sentry/error tracking
    Sentry.capture_exception(e) if defined?(Sentry)
  end

  # ==================== Event Handlers ====================

  def handle_ticket_created(event)
    # Send webhook to Discord bot
    payload = event.payload.deep_symbolize_keys
    
    DiscordWebhookService.notify_ticket_created(
      ticket_id: event.aggregate_id,
      ticket_number: payload[:ticket_number],
      customer_email: payload[:customer_email],
      customer_name: payload[:customer_name],
      message: payload[:message],
      workspace_id: payload[:workspace_id]
    )
  end

  def handle_ticket_updated(event)
    payload = event.payload.deep_symbolize_keys
    
    DiscordWebhookService.notify_ticket_updated(
      ticket_id: event.aggregate_id,
      status: payload[:status],
      assigned_to: payload[:assigned_to]
    )
  end

  def handle_ticket_closed(event)
    payload = event.payload.deep_symbolize_keys
    
    DiscordWebhookService.notify_ticket_closed(
      ticket_id: event.aggregate_id,
      discord_thread_id: payload[:discord_thread_id]
    )
  end

  def handle_message_from_customer(event)
    payload = event.payload.deep_symbolize_keys
    
    DiscordWebhookService.send_customer_message(
      ticket_id: event.aggregate_id,
      discord_thread_id: payload[:discord_thread_id],
      message: payload[:message],
      customer_name: payload[:customer_name]
    )
  end

  def handle_message_from_agent(event)
    # Agent messages come FROM Discord, so we push to widget via SSE
    # This is handled by WidgetBroadcastService when the message is created
    Rails.logger.info "[OutboxProcessor] Agent message - SSE broadcast handled separately"
  end
end
