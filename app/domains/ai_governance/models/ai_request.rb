class AiRequest < ApplicationRecord
  belongs_to :workspace
  belongs_to :user, optional: true
  belongs_to :ticket, optional: true
  
  enum status: {
    pending: "pending",
    success: "success",
    failed: "failed",
    rate_limited: "rate_limited"
  }
  
  validates :model, presence: true
  validates :request_type, presence: true
  
  scope :successful, -> { where(status: "success") }
  scope :failed, -> { where(status: "failed") }
  scope :recent, -> { order(created_at: :desc) }
  
  def self.total_cost_cents(workspace)
    where(workspace: workspace, status: "success").sum(:cost_cents)
  end
  
  def self.total_tokens(workspace)
    where(workspace: workspace, status: "success").sum(:tokens_used)
  end
end