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

ActiveRecord::Schema[7.1].define(version: 2026_02_15_235500) do
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

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "provider"
    t.string "uid"
    t.string "email"
    t.string "name"
    t.string "avatar_url"
    t.json "raw_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
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

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
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
    t.uuid "widget_session_id"
    t.string "source_url"
    t.index ["assigned_to_id"], name: "index_tickets_on_assigned_to_id"
    t.index ["category"], name: "index_tickets_on_category"
    t.index ["closed_at"], name: "index_tickets_on_closed_at"
    t.index ["created_at"], name: "index_tickets_on_created_at"
    t.index ["customer_id"], name: "index_tickets_on_customer_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["subcategory"], name: "index_tickets_on_subcategory"
    t.index ["widget_session_id"], name: "index_tickets_on_widget_session_id"
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
    t.string "avatar_url"
    t.string "language"
    t.string "time_zone"
    t.string "onboarding_phase", default: "created"
    t.index ["discord_user_id"], name: "index_users_on_discord_user_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_status"], name: "index_users_on_invitation_status"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["platform_admin"], name: "index_users_on_platform_admin"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["two_factor_verified"], name: "index_users_on_two_factor_verified"
    t.index ["workspace_id"], name: "index_users_on_workspace_id"
  end

  create_table "widget_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.string "public_key", null: false
    t.string "secret_key", null: false
    t.string "label", default: "Default", null: false
    t.text "allowed_domains", default: [], array: true
    t.datetime "last_used_at"
    t.integer "requests_count", default: 0
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_key"], name: "index_widget_keys_on_public_key", unique: true
    t.index ["status"], name: "index_widget_keys_on_status"
    t.index ["workspace_id"], name: "index_widget_keys_on_workspace_id"
  end

  create_table "widget_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.uuid "customer_id"
    t.string "session_token", null: false
    t.string "fingerprint"
    t.string "page_url"
    t.string "referrer"
    t.jsonb "metadata", default: {}
    t.boolean "websocket_connected", default: false
    t.datetime "last_seen_at"
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_widget_sessions_on_customer_id"
    t.index ["expires_at"], name: "index_widget_sessions_on_expires_at"
    t.index ["session_token"], name: "index_widget_sessions_on_session_token", unique: true
    t.index ["workspace_id", "websocket_connected"], name: "index_widget_sessions_active"
    t.index ["workspace_id"], name: "index_widget_sessions_on_workspace_id"
  end

  create_table "workspace_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "workspace_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_workspace_memberships_on_role"
    t.index ["user_id", "workspace_id"], name: "index_workspace_memberships_on_user_id_and_workspace_id", unique: true
    t.index ["user_id"], name: "index_workspace_memberships_on_user_id"
    t.index ["workspace_id"], name: "index_workspace_memberships_on_workspace_id"
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
    t.string "widget_api_key"
    t.string "widget_secret_key"
    t.string "allowed_domains", default: [], array: true
    t.jsonb "widget_settings", default: {"theme"=>"light", "greeting"=>"Hi! How can we help you today?", "position"=>"bottom-right", "require_email"=>true, "show_branding"=>true, "offline_message"=>"We are currently offline. Leave a message and we will get back to you."}
    t.string "time_zone"
    t.string "language"
    t.string "company_url"
    t.index ["lockdown_activated_by_id"], name: "index_workspaces_on_lockdown_activated_by_id"
    t.index ["lockdown_mode"], name: "index_workspaces_on_lockdown_mode"
    t.index ["slug"], name: "index_workspaces_on_slug", unique: true
    t.index ["widget_api_key"], name: "index_workspaces_on_widget_api_key", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ai_requests", "tickets"
  add_foreign_key "ai_requests", "users"
  add_foreign_key "ai_requests", "workspaces"
  add_foreign_key "api_keys", "users", column: "created_by_id"
  add_foreign_key "api_keys", "workspaces"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "audit_logs", "workspaces"
  add_foreign_key "customers", "workspaces"
  add_foreign_key "discord_guilds", "workspaces"
  add_foreign_key "identities", "users"
  add_foreign_key "messages", "customers"
  add_foreign_key "messages", "tickets"
  add_foreign_key "messages", "users"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "tickets", "customers"
  add_foreign_key "tickets", "users", column: "assigned_to_id"
  add_foreign_key "tickets", "widget_sessions"
  add_foreign_key "tickets", "workspaces"
  add_foreign_key "users", "workspaces"
  add_foreign_key "widget_keys", "workspaces"
  add_foreign_key "widget_sessions", "customers"
  add_foreign_key "widget_sessions", "workspaces"
  add_foreign_key "workspace_memberships", "users"
  add_foreign_key "workspace_memberships", "workspaces"
  add_foreign_key "workspaces", "users", column: "lockdown_activated_by_id"
end
