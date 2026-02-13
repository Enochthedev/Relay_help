class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets, id: :uuid do |t|
      t.references :customer, type: :uuid, null: false, foreign_key: true, index: false
      t.references :workspace, type: :uuid, null: false, foreign_key: true, index: false
      t.references :assigned_to, type: :uuid, foreign_key: { to_table: :users }, null: true, index: false
      t.string :ticket_number, null: false
      t.string :subject, null: false
      t.text :description, null: false
      t.string :status, default: "open"
      t.string :priority, default: "normal"
      t.string :source, null: false
      t.string :category, null: false
      t.string :subcategory, null: false
      t.string :tags, array: true, default: []
      t.string :discord_thread_id
      t.text :ai_summary 

      t.timestamps
    end
    
    add_index :tickets, [:workspace_id, :ticket_number], unique: true, name: "index_tickets_on_workspace_and_number", if_not_exists: true
    add_index :tickets, :status, if_not_exists: true
    add_index :tickets, :customer_id, if_not_exists: true
    add_index :tickets, :workspace_id, if_not_exists: true
    add_index :tickets, :assigned_to_id, if_not_exists: true
    add_index :tickets, :created_at, if_not_exists: true
  end
end
