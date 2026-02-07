class CreateDiscordGuilds < ActiveRecord::Migration[7.1]
  def change
    create_table :discord_guilds, id: :uuid do |t|
      t.references :workspace, type: :uuid, foreign_key: true, null: false, index: false
      t.string :guild_id, null: false
      t.string :guild_name
      t.string :support_channel_id
      t.jsonb :settings, default: {}, null: false

      t.timestamps
    end
    add_index :discord_guilds, :guild_id, unique: true
    add_index :discord_guilds, :workspace_id, unique: true

  end
end
