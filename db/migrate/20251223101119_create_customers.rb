class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers, id: :uuid do |t|
      t.references :workspace, type: :uuid, foreign_key: true
      t.string :email, null: false
      t.string :name
      t.datetime :first_seen_at
      t.datetime :last_seen_at
      t.integer :ticket_balance, default: 0


      t.timestamps
    end
    add_index :customers, [:workspace_id, :email], unique: true, name: "index_customers_on_workspace_and_email"
  end
end
