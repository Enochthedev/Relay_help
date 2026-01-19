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

ActiveRecord::Schema[7.1].define(version: 2026_01_19_111218) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id"
    t.string "email", null: false
    t.string "name"
    t.datetime "first_seen_at"
    t.datetime "last_seen_at"
    t.integer "ticket_balance", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "email"], name: "index_customers_on_workspace_and_email", unique: true
    t.index ["workspace_id"], name: "index_customers_on_workspace_id"
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
    t.index ["assigned_to_id"], name: "index_tickets_on_assigned_to_id"
    t.index ["category"], name: "index_tickets_on_category"
    t.index ["created_at"], name: "index_tickets_on_created_at"
    t.index ["customer_id"], name: "index_tickets_on_customer_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["subcategory"], name: "index_tickets_on_subcategory"
    t.index ["workspace_id", "ticket_number"], name: "index_tickets_on_workspace_and_number", unique: true
    t.index ["workspace_id"], name: "index_tickets_on_workspace_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
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
    t.index ["discord_user_id"], name: "index_users_on_discord_user_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["platform_admin"], name: "index_users_on_platform_admin"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
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
    t.index ["slug"], name: "index_workspaces_on_slug", unique: true
  end

  add_foreign_key "customers", "workspaces"
  add_foreign_key "tickets", "customers"
  add_foreign_key "tickets", "users", column: "assigned_to_id"
  add_foreign_key "tickets", "workspaces"
  add_foreign_key "users", "workspaces"
end
