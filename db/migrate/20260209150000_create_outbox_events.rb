# frozen_string_literal: true

# Migration for Outbox Pattern with PostgreSQL LISTEN/NOTIFY
# This enables reliable, near-instant event delivery without Redis
class CreateOutboxEvents < ActiveRecord::Migration[7.1]
  def up
    create_table :outbox_events, id: :uuid do |t|
      t.string :event_type, null: false          # e.g., "ticket.created", "message.from_customer"
      t.string :aggregate_type, null: false      # e.g., "Ticket", "Message"
      t.uuid :aggregate_id, null: false          # ID of the entity that changed
      t.jsonb :payload, null: false, default: {} # Event data
      t.string :status, null: false, default: 'pending'  # pending, processing, completed, failed
      t.integer :attempts, null: false, default: 0
      t.string :last_error
      t.datetime :processed_at
      t.datetime :created_at, null: false
    end

    add_index :outbox_events, :status
    add_index :outbox_events, :event_type
    add_index :outbox_events, :created_at
    add_index :outbox_events, [:aggregate_type, :aggregate_id]

    # Create PostgreSQL function to notify on new events
    execute <<-SQL
      CREATE OR REPLACE FUNCTION notify_outbox_event()
      RETURNS trigger AS $$
      BEGIN
        PERFORM pg_notify('outbox_events', NEW.id::text);
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    # Create trigger to call the function on INSERT
    execute <<-SQL
      CREATE TRIGGER outbox_event_notify
      AFTER INSERT ON outbox_events
      FOR EACH ROW
      EXECUTE FUNCTION notify_outbox_event();
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS outbox_event_notify ON outbox_events"
    execute "DROP FUNCTION IF EXISTS notify_outbox_event()"
    drop_table :outbox_events
  end
end
