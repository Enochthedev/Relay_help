class Customer < ApplicationRecord
  # Associations
  belongs_to :workspace
  has_many :tickets, dependent: :destroy
  has_many :messages, dependent: :nullify
  has_many :widget_sessions, dependent: :destroy

  # Validations
  # Email is optional for anonymous widget users (they can provide it later)
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, uniqueness: { scope: :workspace_id }, allow_blank: true
  # Either email or fingerprint must be present
  validate :email_or_fingerprint_present

  # Callbacks
  before_create :set_first_seen
  after_create :set_last_seen

  # Scopes
  scope :active, -> { where("last_seen_at > ?", 30.days.ago) }
  scope :inactive, -> { where("last_seen_at <= ? OR last_seen_at IS NULL", 30.days.ago) }
  scope :frequent, -> { where("total_tickets >= ?", 5) }
  scope :recent, -> { order(last_seen_at: :desc) }
  scope :identified, -> { where.not(email: [nil, '']) }
  scope :anonymous, -> { where(email: [nil, '']) }

  # Instance methods
  def update_last_seen!
    update!(last_seen_at: Time.current)
  end

  def increment_ticket_count!
    increment!(:total_tickets)
  end

  def display_name
    name.presence || email.split("@").first
  end

  def active?
    last_seen_at && last_seen_at > 30.days.ago
  end

  def identified?
    email.present?
  end

  def anonymous?
    !identified?
  end

  # Upgrade anonymous customer to identified
  def identify!(email:, name: nil)
    update!(email: email, name: name)
  end

  # Find or create customer by fingerprint (for anonymous users)
  def self.find_or_create_by_fingerprint(workspace:, fingerprint:, attrs: {})
    customer = workspace.customers.find_by(fingerprint: fingerprint)
    return customer if customer

    workspace.customers.create!(
      fingerprint: fingerprint,
      name: attrs[:name],
      browser_info: attrs[:browser_info] || {}
    )
  end

  # Find or create customer by email (for identified users)
  def self.find_or_create_by_email(workspace:, email:, attrs: {})
    customer = workspace.customers.find_by(email: email.downcase)
    return customer if customer

    workspace.customers.create!(
      email: email.downcase,
      name: attrs[:name],
      fingerprint: attrs[:fingerprint]
    )
  end

  private

  def set_first_seen
    self.first_seen_at ||= Time.current
  end

  def set_last_seen
    self.last_seen_at ||= Time.current
  end

  def email_or_fingerprint_present
    if email.blank? && fingerprint.blank?
      errors.add(:base, "Either email or fingerprint must be present")
    end
  end
end