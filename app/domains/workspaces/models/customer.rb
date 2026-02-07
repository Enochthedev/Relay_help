class Customer < ApplicationRecord
  # Associations
  belongs_to :workspace
  has_many :tickets, dependent: :destroy
  has_many :messages, dependent: :nullify

  #Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :workspace_id }

  #Callbacks
  before_create :set_first_seen
  after_create :set_last_seen

  # Scopes
  scope :active, -> { where("last_seen_at > ?", 30.days.ago) }
  scope :inactive, -> { where("last_seen_at <= ? OR last_seen_at IS NULL", 30.days.ago) }
  scope :frequent, -> { where("ticket_balance >= ?", 5) }
  scope :recent, -> { order(last_seen_at: :desc) }

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



private

  def set_first_seen
    self.first_seen_at ||= Time.current
  end

  def set_last_seen
    self.last_seen_at ||= Time.current
  end


end