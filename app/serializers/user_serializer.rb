# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :name, :role

  attribute :workspace_id do |user|
    user.workspace_id
  end

  attribute :workspace do |user|
    {
      id: user.workspace.id,
      name: user.workspace.name,
      slug: user.workspace.slug
    }
  end

  attribute :discord_connected do |user|
    user.discord_connected?
  end

  attribute :can_login do |user|
    user.can_login?
  end

  attribute :workspaces do |user|
    user.workspaces.map do |ws|
      {
        id: ws.id,
        name: ws.name,
        slug: ws.slug,
        role: user.workspace_memberships.find_by(workspace_id: ws.id)&.role
      }
    end
  end

  attribute :onboarding_complete do |user|
    !user.needs_onboarding?
  end
end
