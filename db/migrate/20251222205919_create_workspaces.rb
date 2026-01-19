class CreateWorkspaces < ActiveRecord::Migration[7.1]
  def change
    create_table :workspaces, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :plan, null: false, default: "free"
      t.integer :ai_token_balance, null: false, default: 0
      t.integer :monthly_ticket_limit, null: false, default: 100
      t.integer :tickets_used_this_month, null: false, default: 0
      t.jsonb :settings, default: {}
      t.datetime :last_reset_at
      t.timestamps 
    end
    add_index :workspaces, :slug, unique: true
  end
end
