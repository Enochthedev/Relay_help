class Workspace < ApplicationRecord

  before_validation :generate_slug, on: :create

  enum plan: {
    free: "free",
    starter: "starter",
    pro: "pro",
    enterprise: "enterprise"
  }

  # Associations
  has_many :users, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :ai_requests, dependent: :destroy
  has_one :discord_guild, dependent: :destroy
  belongs_to :lockdown_activated_by, class_name: "User", optional: true
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :plan, inclusion: { in: %w[free starter pro enterprise] }
  
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
  
  private 
  
  def generate_slug
    self.slug = name.parameterize
  end


end
