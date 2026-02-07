class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :ticket, type: :uuid, foreign_key: true, null: false
      t.references :user, type: :uuid, foreign_key: true, null: true
      t.references :customer, type: :uuid, foreign_key: true, null: true

      t.text :body, null: false
      t.string :message_type, null: false
      t.string :discord_message_id
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    # t.references already creates indexes for ticket_id, user_id, customer_id
    add_index :messages, :message_type
    add_index :messages, :created_at
  end
end
