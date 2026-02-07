class CreateApiKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.references :workspace, type: :uuid, foreign_key: true, null: false
      t.string :name, null: false
      t.string :key_hash, null: false
      t.string :key_prefix, null: false
      t.jsonb :permissions, default: {}, null: false
      t.datetime :last_used_at
      t.datetime :expires_at
      t.references :created_by, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :api_keys, :key_hash, unique: true
    add_index :api_keys, :revoked_at
  end
end
