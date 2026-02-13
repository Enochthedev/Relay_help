class WorkspaceMembership < ApplicationRecord
  belongs_to :user
  belongs_to :workspace

  enum role: {
    member: "member",
    admin: "admin",
    owner: "owner"
  }

  validates :user_id, uniqueness: { scope: :workspace_id, message: "is already a member of this workspace" }
  validates :role, presence: true
end
