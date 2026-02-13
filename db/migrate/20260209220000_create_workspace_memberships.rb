class CreateWorkspaceMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :workspace_memberships, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.string :role, null: false, default: "member"

      t.timestamps
    end

    add_index :workspace_memberships, [:user_id, :workspace_id], unique: true
    add_index :workspace_memberships, :role

    # Backfill existing data
    User.reset_column_information
    User.find_each do |user|
      next unless user.workspace_id

      # Use the user's current role for the workspace membership
      # Default to 'member' if role is missing (though it shouldn't be)
      role = user.role || "member"
      
      WorkspaceMembership.create!(
        user_id: user.id,
        workspace_id: user.workspace_id,
        role: role
      )
    end
  end
end
