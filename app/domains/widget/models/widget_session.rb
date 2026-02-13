# frozen_string_literal: true

# Tracks active widget sessions for real-time communication
# Each browser tab with the widget open creates a session
class WidgetSession < ApplicationRecord
  belongs_to :workspace
  belongs_to :customer, optional: true

  # Token is used to authenticate widget requests
  attr_accessor :raw_token

  before_validation :generate_session_token, on: :create
  before_validation :set_expiry, on: :create

  # Scopes
  scope :active, -> { where('expires_at > ?', Time.current).where(websocket_connected: true) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :for_workspace, ->(workspace) { where(workspace: workspace) }

  # Validations
  validates :session_token, presence: true, uniqueness: true

  # Generate a new session for a widget visitor
  def self.create_for_visitor(workspace:, fingerprint:, customer: nil, metadata: {})
    session = new(
      workspace: workspace,
      customer: customer,
      fingerprint: fingerprint,
      metadata: metadata,
      page_url: metadata[:page_url],
      referrer: metadata[:referrer]
    )
    session.save!
    session
  end

  # Find session by token (used for widget API authentication)
  # Only checks expiry — websocket_connected is irrelevant for HTTP API requests
  def self.find_by_token(token)
    return nil if token.blank?
    
    where('expires_at > ?', Time.current).find_by(session_token: token)
  end

  # Mark session as connected (WebSocket opened)
  def connect!
    update!(websocket_connected: true, last_seen_at: Time.current)
  end

  # Mark session as disconnected
  def disconnect!
    update!(websocket_connected: false, last_seen_at: Time.current)
  end

  # Update last seen timestamp (heartbeat)
  def heartbeat!
    update!(last_seen_at: Time.current)
  end

  # Check if session is still valid
  def valid_session?
    expires_at > Time.current
  end

  # Extend session expiry
  def extend_expiry!
    update!(expires_at: 24.hours.from_now)
  end

  # Associate customer with session (when they provide email)
  def associate_customer!(customer)
    update!(customer: customer)
  end

  private

  def generate_session_token
    self.session_token = SecureRandom.urlsafe_base64(32)
    self.raw_token = session_token  # Expose the token before save
  end

  def set_expiry
    self.expires_at ||= 24.hours.from_now
  end
end
