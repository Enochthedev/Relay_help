class AuditLog < ApplicationRecord
  belongs_to :workspace
  belongs_to :user, optional: true
  
  validates :action, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_action, ->(action) { where(action: action) }
  scope :for_resource, ->(type, id) { where(resource_type: type, resource_id: id) }
  
  def self.log!(workspace:, user: nil, action:, resource: nil, metadata: {}, request: nil)
    create!(
      workspace: workspace,
      user: user,
      action: action,
      resource_type: resource&.class&.name,
      resource_id: resource&.id,
      change_data: metadata,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end
end