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

ActiveRecord::Schema[7.1].define(version: 2026_01_21_175853) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

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
    t.string "email", null: false
    t.string "name"
    t.datetime "first_seen_at"
    t.datetime "last_seen_at"
    t.integer "total_tickets", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "email"], name: "index_customers_on_workspace_and_email", unique: true
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

  create_table "tickets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.uuid "workspace_id", null: false
    t.uuid "assigned_to_id"
    t.string "ticket_number", null: false
    t.string "subject", null: false
    t.text "description", null: false
    t.string "status", default: "open"
    t.string "priority", default: "normal"
    t.string "source", null: false
    t.string "category", null: false
    t.string "subcategory", null: false
    t.string "tags", default: [], array: true
    t.string "discord_thread_id"
    t.text "ai_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sla_target"
    t.datetime "closed_at"
    t.index ["assigned_to_id"], name: "index_tickets_on_assigned_to_id"
    t.index ["category"], name: "index_tickets_on_category"
    t.index ["closed_at"], name: "index_tickets_on_closed_at"
    t.index ["created_at"], name: "index_tickets_on_created_at"
    t.index ["customer_id"], name: "index_tickets_on_customer_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["subcategory"], name: "index_tickets_on_subcategory"
    t.index ["workspace_id", "ticket_number"], name: "index_tickets_on_workspace_and_number", unique: true
    t.index ["workspace_id"], name: "index_tickets_on_workspace_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.uuid "workspace_id", null: false
    t.string "name"
    t.string "role", default: "member", null: false
    t.boolean "platform_admin", default: false, null: false
    t.string "discord_user_id"
    t.string "discord_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_status", default: "pending"
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.boolean "two_factor_verified", default: false, null: false
    t.datetime "email_verified_at"
    t.datetime "discord_connected_at"
    t.index ["discord_user_id"], name: "index_users_on_discord_user_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_status"], name: "index_users_on_invitation_status"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["platform_admin"], name: "index_users_on_platform_admin"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["two_factor_verified"], name: "index_users_on_two_factor_verified"
    t.index ["workspace_id"], name: "index_users_on_workspace_id"
  end

  create_table "workspaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "plan", default: "free", null: false
    t.integer "ai_token_balance", default: 0, null: false
    t.integer "monthly_ticket_limit", default: 100, null: false
    t.integer "tickets_used_this_month", default: 0, null: false
    t.jsonb "settings", default: {}
    t.datetime "last_reset_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "lockdown_mode", default: false, null: false
    t.string "lockdown_reason"
    t.datetime "lockdown_activated_at"
    t.uuid "lockdown_activated_by_id"
    t.index ["lockdown_activated_by_id"], name: "index_workspaces_on_lockdown_activated_by_id"
    t.index ["lockdown_mode"], name: "index_workspaces_on_lockdown_mode"
    t.index ["slug"], name: "index_workspaces_on_slug", unique: true
  end

  add_foreign_key "ai_requests", "tickets"
  add_foreign_key "ai_requests", "users"
  add_foreign_key "ai_requests", "workspaces"
  add_foreign_key "api_keys", "users", column: "created_by_id"
  add_foreign_key "api_keys", "workspaces"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "audit_logs", "workspaces"
  add_foreign_key "customers", "workspaces"
  add_foreign_key "discord_guilds", "workspaces"
  add_foreign_key "messages", "customers"
  add_foreign_key "messages", "tickets"
  add_foreign_key "messages", "users"
  add_foreign_key "tickets", "customers"
  add_foreign_key "tickets", "users", column: "assigned_to_id"
  add_foreign_key "tickets", "workspaces"
  add_foreign_key "users", "workspaces"
  add_foreign_key "workspaces", "users", column: "lockdown_activated_by_id"
end
