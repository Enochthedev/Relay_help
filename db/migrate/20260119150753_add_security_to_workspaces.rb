class AddSecurityToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_column :workspaces, :lockdown_mode, :boolean, default: false, null: false
    add_column :workspaces, :lockdown_reason, :string
    add_column :workspaces, :lockdown_activated_at, :datetime
    add_reference :workspaces, :lockdown_activated_by, type: :uuid, foreign_key: { to_table: :users }
    
    add_index :workspaces, :lockdown_mode
  end
end
