class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :workspace, type: :uuid, foreign_key: true, null: false
      t.references :user, type: :uuid, foreign_key: true, null: true
      t.string :action, null: false
      t.string :resource_type
      t.uuid :resource_id
      t.jsonb :changes, default: {}, null: false
      t.string :ip_address
      t.string :user_agent
      t.datetime :created_at, null: false
    end
    add_index :audit_logs, :created_at
    add_index :audit_logs, [:workspace_id, :created_at]
    add_index :audit_logs, [:resource_type, :resource_id]
    add_index :audit_logs, :action
  end
end
