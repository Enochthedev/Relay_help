class CreateWidgetKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :widget_keys, id: :uuid do |t|
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.string :public_key, null: false
      t.string :secret_key, null: false
      t.string :label, null: false, default: "Default"
      t.text :allowed_domains, array: true, default: []
      t.datetime :last_used_at
      t.integer :requests_count, default: 0
      t.string :status, default: "active"

      t.timestamps
    end

    add_index :widget_keys, :public_key, unique: true
    add_index :widget_keys, :status
    
    # Backfill existing keys
    Workspace.reset_column_information
    Workspace.find_each do |workspace|
      next unless workspace.widget_api_key

      WidgetKey.create!(
        workspace_id: workspace.id,
        public_key: workspace.widget_api_key,
        secret_key: workspace.widget_secret_key || SecureRandom.hex(32),
        label: "Legacy Key",
        allowed_domains: workspace.allowed_domains || [],
        status: "active"
      )
    end
  end
end
