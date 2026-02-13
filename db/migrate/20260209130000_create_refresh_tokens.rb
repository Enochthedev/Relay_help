class CreateRefreshTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :refresh_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token_digest, null: false  # Hashed token for security
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end

    add_index :refresh_tokens, :token_digest, unique: true
    add_index :refresh_tokens, :expires_at
    add_index :refresh_tokens, [:user_id, :revoked_at]
  end
end
