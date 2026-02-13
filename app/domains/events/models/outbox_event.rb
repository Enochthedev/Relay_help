# frozen_string_literal: true

# OutboxEvent stores events for reliable delivery to external systems
# Uses PostgreSQL LISTEN/NOTIFY for near-instant processing
class OutboxEvent < ApplicationRecord
  # Statuses
  PENDING = 'pending'
  PROCESSING = 'processing'
  COMPLETED = 'completed'
  FAILED = 'failed'

  # Event Types
  TICKET_CREATED = 'ticket.created'
  TICKET_UPDATED = 'ticket.updated'
  TICKET_CLOSED = 'ticket.closed'
  MESSAGE_FROM_CUSTOMER = 'message.from_customer'
  MESSAGE_FROM_AGENT = 'message.from_agent'

  # Validations
  validates :event_type, presence: true
  validates :aggregate_type, presence: true
  validates :aggregate_id, presence: true
  validates :status, inclusion: { in: [PENDING, PROCESSING, COMPLETED, FAILED] }

  # Scopes
  scope :pending, -> { where(status: PENDING) }
  scope :failed, -> { where(status: FAILED) }
  scope :retryable, -> { failed.where('attempts < 5') }

  # Create an outbox event (called within the same transaction as business logic)
  def self.publish!(event_type:, aggregate:, payload: {})
    create!(
      event_type: event_type,
      aggregate_type: aggregate.class.name,
      aggregate_id: aggregate.id,
      payload: payload,
      status: PENDING
    )
  end

  # Mark as being processed
  def start_processing!
    update!(status: PROCESSING)
  end

  # Mark as completed
  def complete!
    update!(status: COMPLETED, processed_at: Time.current)
  end

  # Mark as failed
  def fail!(error_message)
    update!(
      status: FAILED,
      attempts: attempts + 1,
      last_error: error_message.truncate(500)
    )
  end

  # Retry a failed event
  def retry!
    update!(status: PENDING)
  end

  # Can this event be retried?
  def retryable?
    failed? && attempts < 5
  end

  def pending?
    status == PENDING
  end

  def failed?
    status == FAILED
  end

  def completed?
    status == COMPLETED
  end
end
