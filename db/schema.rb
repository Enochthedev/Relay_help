# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_02_15_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ai_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.uuid "user_id"
    t.uuid "ticket_id"
    t.string "model", null: false
    t.string "request_type", null: false
    t.text "prompt"
    t.text "response"
    t.integer "tokens_used"
    t.integer "cost_cents"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_ai_requests_on_created_at"
    t.index ["status"], name: "index_ai_requests_on_status"
    t.index ["ticket_id"], name: "index_ai_requests_on_ticket_id"
    t.index ["user_id"], name: "index_ai_requests_on_user_id"
    t.index ["workspace_id"], name: "index_ai_requests_on_workspace_id"
  end

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.string "name", null: false
    t.string "key_hash", null: false
    t.string "key_prefix", null: false
    t.jsonb "permissions", default: {}, null: false
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.uuid "created_by_id"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_api_keys_on_created_by_id"
    t.index ["key_hash"], name: "index_api_keys_on_key_hash", unique: true
    t.index ["revoked_at"], name: "index_api_keys_on_revoked_at"
    t.index ["workspace_id"], name: "index_api_keys_on_workspace_id"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.uuid "user_id"
    t.string "action", null: false
    t.string "resource_type"
    t.uuid "resource_id"
    t.jsonb "change_data", default: {}, null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["resource_type", "resource_id"], name: "index_audit_logs_on_resource_type_and_resource_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
    t.index ["workspace_id", "created_at"], name: "index_audit_logs_on_workspace_id_and_created_at"
    t.index ["workspace_id"], name: "index_audit_logs_on_workspace_id"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id"
    t.string "email"
    t.string "name"
    t.datetime "first_seen_at"
    t.datetime "last_seen_at"
    t.integer "total_tickets", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fingerprint"
    t.jsonb "browser_info", default: {}
    t.index ["workspace_id", "email"], name: "index_customers_on_workspace_and_email", unique: true
    t.index ["workspace_id", "fingerprint"], name: "index_customers_on_workspace_and_fingerprint"
    t.index ["workspace_id"], name: "index_customers_on_workspace_id"
  end

  create_table "discord_guilds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.string "guild_id", null: false
    t.string "guild_name"
    t.string "support_channel_id"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guild_id"], name: "index_discord_guilds_on_guild_id", unique: true
    t.index ["workspace_id"], name: "index_discord_guilds_on_workspace_id", unique: true
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti", unique: true
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ticket_id", null: false
    t.uuid "user_id"
    t.uuid "customer_id"
    t.text "body", null: false
    t.string "message_type", null: false
    t.string "discord_message_id"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["customer_id"], name: "index_messages_on_customer_id"
    t.index ["message_type"], name: "index_messages_on_message_type"
    t.index ["ticket_id"], name: "index_messages_on_ticket_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "outbox_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event_type", null: false
    t.string "aggregate_type", null: false
    t.uuid "aggregate_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.integer "attempts", default: 0, null: false
    t.string "last_error"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.index ["aggregate_type", "aggregate_id"], name: "index_outbox_events_on_aggregate_type_and_aggregate_id"
    t.index ["created_at"], name: "index_outbox_events_on_created_at"
    t.index ["event_type"], name: "index_outbox_events_on_event_type"
    t.index ["status"], name: "index_outbox_events_on_status"
  end

  create_table "refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_refresh_tokens_on_expires_at"
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id", "revoked_at"], name: "index_refresh_tokens_on_user_id_and_revoked_at"
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

