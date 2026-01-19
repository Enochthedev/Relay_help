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
  
  private 
  
  def generate_slug
    self.slug = name.parameterize
  end
end
