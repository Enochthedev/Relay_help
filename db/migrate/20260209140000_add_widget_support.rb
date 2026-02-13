# frozen_string_literal: true

# Migration to add widget support for the embeddable support widget
# This enables the customer-facing widget that connects to Discord
class AddWidgetSupport < ActiveRecord::Migration[7.1]
  def change
    # 1. Add widget configuration to workspaces
    add_column :workspaces, :widget_api_key, :string
    add_column :workspaces, :widget_secret_key, :string  # For signing widget requests
    add_column :workspaces, :allowed_domains, :string, array: true, default: []
    add_column :workspaces, :widget_settings, :jsonb, default: {
      theme: 'light',
      position: 'bottom-right',
      greeting: 'Hi! How can we help you today?',
      offline_message: 'We are currently offline. Leave a message and we will get back to you.',
      require_email: true,
      show_branding: true
    }
    
    add_index :workspaces, :widget_api_key, unique: true

    # 2. Add fingerprint to customers for anonymous widget users
    # Customers can start anonymous and later provide email
    add_column :customers, :fingerprint, :string
    add_column :customers, :browser_info, :jsonb, default: {}
    
    # Make email optional (anonymous users won't have one initially)
    change_column_null :customers, :email, true
    
    add_index :customers, [:workspace_id, :fingerprint], name: 'index_customers_on_workspace_and_fingerprint'

    # 3. Create widget_sessions table for real-time tracking
    create_table :widget_sessions, id: :uuid do |t|
      t.references :workspace, type: :uuid, foreign_key: true, null: false
      t.references :customer, type: :uuid, foreign_key: true
      t.string :session_token, null: false
      t.string :fingerprint
      t.string :page_url
      t.string :referrer
      t.jsonb :metadata, default: {}
      t.boolean :websocket_connected, default: false
      t.datetime :last_seen_at
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :widget_sessions, :session_token, unique: true
    add_index :widget_sessions, :expires_at
    add_index :widget_sessions, [:workspace_id, :websocket_connected], name: 'index_widget_sessions_active'

    # 4. Link tickets to widget sessions
    add_reference :tickets, :widget_session, type: :uuid, foreign_key: true
    add_column :tickets, :source_url, :string  # URL where ticket was created
  end
end
