class WorkspaceSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :slug, :plan, :created_at, :ai_token_balance
  
  attribute :owner_email do |workspace|
    workspace.users.find_by(role: 'owner')&.email
  end

  attribute :tickets_count do |workspace|
    workspace.tickets.count
  end
end
