class CreateAiRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_requests, id: :uuid do |t|
      t.references :workspace, type: :uuid, foreign_key: true, null: false
      t.references :user, type: :uuid, foreign_key: true, null: true
      t.references :ticket, type: :uuid, foreign_key: true, null: true
      t.string :model, null: false
      t.string :request_type, null: false
      t.text :prompt
      t.text :response
      t.integer :tokens_used
      t.integer :cost_cents
      t.string :status, null: false
      t.datetime :created_at, null: false
    end
    add_index :ai_requests, :created_at
    add_index :ai_requests, :status
  end
end
