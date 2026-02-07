class Message < ApplicationRecord
  # Associations
  belongs_to :ticket
  belongs_to :user, optional: true
  belongs_to :customer, optional: true

  # Enums
  enum message_type: {
    customer: "customer",
    agent: "agent",
    ai: "ai",
    internal: "internal",
    system: "system"
  }

  # Validations
  validates :body, presence: true
  validates :message_type, presence: true
  validate :sender_presence

  # Scopes
  scope :public_messages, -> { where.not(message_type: "internal") }
  scope :internal_only, -> { where(message_type: "internal") }
  scope :from_customer, -> { where.not(customer_id: nil) }
  scope :from_agent, -> { where.not(user_id: nil) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }
  scope :with_discord, -> { where.not(discord_message_id: nil) }

  # Callbacks
  after_create :touch_ticket

  # Instance methods

  def sender_email
    return user.email if user.present?
    return customer.email if customer.present?
    nil
  end

  def from_customer?
    customer_id.present?
  end

  def from_agent?
    user_id.present?
  end

  def synced_to_discord?
    discord_message_id.present?
  end

  def author
    customer || user
  end

  def author_name
    author&.display_name || "System"
  end

  def visible_to_customer?
    !internal?
  end



  private

  def sender_presence
    # For customer messages, must have customer_id
    if customer? && customer_id.nil?
      errors.add(:customer_id, "Customer ID is required for customer messages")
    end
    # For agent messages, must have user_id
    if agent? && user_id.nil?
      errors.add(:user_id, "User ID is required for agent messages")
    end

    # Both user and customer id cannot be present
    if user_id.present? && customer_id.present?
      errors.add(:base, "Both user_id and customer_id cannot be present")
    end

  end

  def touch_ticket
    ticket.touch
  end
end
