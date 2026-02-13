# frozen_string_literal: true

# Fallback job to process any pending outbox events
# Main processing happens via PostgreSQL LISTEN/NOTIFY, but this catches any stragglers
class OutboxProcessorJob < ApplicationJob
  queue_as :default

  def perform
    processed = 0
    
    OutboxEvent.pending.order(:created_at).limit(100).each do |event|
      process_event(event)
      processed += 1
    end

    Rails.logger.info "[OutboxProcessorJob] Processed #{processed} pending events" if processed > 0
  end

  private

  def process_event(event)
    event.start_processing!

    case event.event_type
    when OutboxEvent::TICKET_CREATED
      handle_ticket_created(event)
    when OutboxEvent::MESSAGE_FROM_CUSTOMER
      handle_message_from_customer(event)
    when OutboxEvent::TICKET_CLOSED
      handle_ticket_closed(event)
    end

    event.complete!
  rescue StandardError => e
    Rails.logger.error "[OutboxProcessorJob] Failed: #{event.event_type} - #{e.message}"
    event.fail!(e.message)
    Sentry.capture_exception(e) if defined?(Sentry)
  end

  def handle_ticket_created(event)
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

  def handle_message_from_customer(event)
    payload = event.payload.deep_symbolize_keys
    
    DiscordWebhookService.send_customer_message(
      ticket_id: event.aggregate_id,
      discord_thread_id: payload[:discord_thread_id],
      message: payload[:message],
      customer_name: payload[:customer_name]
    )
  end

  def handle_ticket_closed(event)
    payload = event.payload.deep_symbolize_keys
    
    DiscordWebhookService.notify_ticket_closed(
      ticket_id: event.aggregate_id,
      discord_thread_id: payload[:discord_thread_id]
    )
  end
end
