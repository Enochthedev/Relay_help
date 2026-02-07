class Ticket < ApplicationRecord
  # Associations
  belongs_to :customer
  belongs_to :workspace
  belongs_to :assigned_to, class_name: "User", optional: true
  has_many :messages, dependent: :destroy

  # Enums
  enum status: {
    open: "open",
    in_progress: "in_progress",
    waiting_on_customer: "waiting_on_customer",
    resolved: "resolved",
    closed: "closed"
  }

  enum priority: {
    low: "low",
    normal: "normal",
    high: "high",
    urgent: "urgent"
  }

  enum source: {
    discord: "discord",
    email: "email",
    web: "web",
    webhook: "webhook",
    api: "api",
    manual: "manual"
  }

  # Validations
  validates :ticket_number, presence: true, uniqueness: { scope: :workspace_id }
  validates :subject, presence: true, length: { minimum: 3, maximum: 500 }
  validates :description, presence: true
  validates :source, presence: true
  validates :category, presence: true
  validates :subcategory, presence: true
  validates :status, presence: true
  validates :priority, presence: true


  # Callbacks
  before_validation :generate_ticket_number, on: :create
  before_validation :set_defaults, on: :create
  after_create :increment_customer_ticket_count
  after_create :update_customer_last_seen

  # Scopes
  scope :open_tickets, -> { where(status: %w[open in_progress waiting_on_customer]) }
  scope :closed_tickets, -> { where(status: %w[resolved closed]) }
  scope :unassigned, -> { where(assigned_to_id: nil) }
  scope :assigned_to_user, ->(user) { where(assigned_to: user) }
  scope :by_priority, -> { order(Arel.sql("CASE priority WHEN 'urgent' THEN 1 WHEN 'high' THEN 2 WHEN 'normal' THEN 3 WHEN 'low' THEN 4 END")) }
  scope :urgent_priority, -> { where(priority: ["high", "urgent"]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_discord_thread, -> { where.not(discord_thread_id: nil) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :by_source, -> { order(source: :asc) }
  scope :by_category, -> { order(category: :asc) }
  scope :by_subcategory, -> { order(subcategory: :asc) }

  # Instance methods
  def assign_to!(user)
    update!(assigned_to: user, status: "in_progress")
  end

  def resolve!
    update!(status: "resolved", closed_at: Time.current)
  end

  def close!
    update!(status: "closed", closed_at: Time.current)
  end

  def open!
    update!(status: "open", closed_at: nil)
  end

  def response_time
    return nil unless closed_at
    closed_at - created_at
  end

  def discord_linked?
    discord_thread_id.present?
  end

  def has_ai_summary?
    ai_summary.present?
  end

  def first_response_time
    return nil unless closed_at
    closed_at - created_at
  end

  def sla_breached?(hours)
    return false if sla_target.nil?
    (Time.current - created_at) > hours.hours
  end

  private

  def generate_ticket_number
    return if ticket_number.present?
    # Get the last ticket number for this workspace
    last_ticket = workspace.tickets.order(created_at: :desc).first
    # Increment the last ticket number
    next_number = last_ticket ? last_ticket.ticket_number.split("-").last.to_i + 1 : 1
    self.ticket_number = "#{workspace.slug.upcase}-#{next_number.to_s.rjust(5, '0')}"
  end

  def increment_customer_ticket_count
    customer.increment_ticket_count!
  end

  def set_defaults
    self.status ||= "open"
    self.priority ||= "normal"
  end

  def update_customer_last_seen
    customer.update_last_seen!
  end
end
