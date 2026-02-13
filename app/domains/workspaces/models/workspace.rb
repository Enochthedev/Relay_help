class Workspace < ApplicationRecord

  before_validation :generate_slug, on: :create
  before_create :generate_widget_keys # Legacy columns
  after_create :create_default_widget_key

  enum plan: {
    free: "free",
    starter: "starter",
    pro: "pro",
    enterprise: "enterprise"
  }

  # Associations
  has_many :workspace_memberships, dependent: :destroy
  has_many :users, through: :workspace_memberships
  has_many :customers, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :ai_requests, dependent: :destroy
  has_many :widget_sessions, dependent: :destroy
  has_many :widget_keys, dependent: :destroy
  has_one :discord_guild, dependent: :destroy
  belongs_to :lockdown_activated_by, class_name: "User", optional: true
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :plan, inclusion: { in: %w[free starter pro enterprise] }
  validates :widget_api_key, uniqueness: true, allow_nil: true
  
  def plan_limits
    case plan
    when "free"
      { ai_token_balance: 1000, tickets: 100 }
    when "starter"
      { ai_token_balance: 5000, tickets: 500 }
    when "pro"
      { ai_token_balance: 10000, tickets: 1000 }
    when "enterprise"
      { ai_token_balance: 25000, tickets: 2500 }
    end
  end

  def within_ticket_limit?
    tickets_used_this_month < plan_limits[:tickets]
  end
  
  def within_token_limit?
    ai_token_balance > 0
  end
  def activate_lockdown!(reason:, activated_by:)
    transaction do
      update!(
        lockdown_mode: true,
        lockdown_reason: reason,
        lockdown_activated_at: Time.current,
        lockdown_activated_by: activated_by
      )
          AuditLog.log!(
        workspace: self,
        user: activated_by,
        action: "workspace.lockdown_activated",
        resource: self,
        metadata: { reason: reason }
      )
    end
  end

  def deactivate_lockdown!(user:)
    transaction do
      update!(
        lockdown_mode: false,
        lockdown_reason: nil,
        lockdown_activated_at: nil,
        lockdown_activated_by: nil
      )
      
      # Log the action
      AuditLog.log!(
        workspace: self,
        user: user,
         action: "workspace.lockdown_deactivated",
        resource: self,
        metadata: {}
      )
    end
  end
  
  def locked_down?
    lockdown_mode == true
  end

  # Widget helpers
  def widget_configured?
    widget_api_key.present?
  end

  def domain_allowed?(domain)
    return true if allowed_domains.blank?  # No restrictions
    allowed_domains.any? { |d| domain.include?(d) }
  end

  def active_widget_sessions_count
    widget_sessions.active.count
  end

  def widget_embed_code
    key = widget_keys.active.first&.public_key || widget_api_key
    <<~HTML
      <script src="https://widget.relayhelp.com/embed.js" 
              data-workspace="#{key}"
              async>
      </script>
    HTML
  end

  def regenerate_widget_keys!
    update!(
      widget_api_key: "rh_#{SecureRandom.hex(16)}",
      widget_secret_key: SecureRandom.hex(32)
    )
    # Create a new key as well
    create_default_widget_key
  end
  
  private 
  
  def generate_slug
    self.slug = name.parameterize
  end

  def generate_widget_keys
    self.widget_api_key ||= "rh_#{SecureRandom.hex(16)}"
    self.widget_secret_key ||= SecureRandom.hex(32)
  end

  def create_default_widget_key
    widget_keys.create!(
      public_key: widget_api_key, # Use the generated legacy key as the first key
      secret_key: widget_secret_key || SecureRandom.hex(32),
      label: "Default Key",
      status: "active"
    )
  end
end
