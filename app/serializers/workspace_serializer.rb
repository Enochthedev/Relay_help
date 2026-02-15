class WorkspaceSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :slug, :plan, :created_at, :ai_token_balance, :time_zone, :language

  attribute :logo_url do |workspace|
    if workspace.logo.attached?
      Rails.application.routes.url_helpers.rails_blob_url(workspace.logo, only_path: false)
    end
  end

  attribute :owner_email do |workspace|
    workspace.users.find_by(role: 'owner')&.email
  end

  attribute :tickets_count do |workspace|
    workspace.tickets.count
  end
end
