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

ActiveRecord::Schema[7.2].define(version: 2026_08_17_200400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
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

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "registration_number", null: false
    t.integer "address_zip_code", null: false
    t.string "address_street", null: false
    t.integer "address_number", null: false
    t.string "address_city", null: false
    t.string "address_complement"
    t.string "address_state", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_type", default: "fleet_operator", null: false
    t.index ["company_type"], name: "index_companies_on_company_type"
    t.index ["registration_number"], name: "index_companies_on_registration_number", unique: true
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "host_units", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "vin", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_host_units_on_company_id"
    t.index ["vin"], name: "index_host_units_on_vin", unique: true
  end

  create_table "lifecycle_events", force: :cascade do |t|
    t.bigint "part_id", null: false
    t.bigint "host_unit_id"
    t.bigint "company_id", null: false
    t.string "event_type", null: false
    t.string "installation_type"
    t.datetime "occurred_at", null: false
    t.integer "age_at_event_days", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_lifecycle_events_on_company_id"
    t.index ["event_type"], name: "index_lifecycle_events_on_event_type"
    t.index ["host_unit_id"], name: "index_lifecycle_events_on_host_unit_id"
    t.index ["part_id", "occurred_at"], name: "index_lifecycle_events_on_part_id_and_occurred_at"
    t.index ["part_id"], name: "index_lifecycle_events_on_part_id"
  end

  create_table "part_type_references", force: :cascade do |t|
    t.string "part_type", null: false
    t.integer "typical_lifespan_days", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["part_type"], name: "index_part_type_references_on_part_type", unique: true
  end

  create_table "parts", force: :cascade do |t|
    t.bigint "part_type_reference_id", null: false
    t.bigint "host_unit_id"
    t.bigint "company_id", null: false
    t.string "serial_number", null: false
    t.string "manufacturer", null: false
    t.string "model", null: false
    t.string "status", default: "installed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_parts_on_company_id"
    t.index ["host_unit_id"], name: "index_parts_on_host_unit_id"
    t.index ["part_type_reference_id", "manufacturer", "model"], name: "index_parts_on_type_manufacturer_model"
    t.index ["part_type_reference_id"], name: "index_parts_on_part_type_reference_id"
    t.index ["serial_number"], name: "index_parts_on_serial_number", unique: true
  end

  create_table "plans", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.integer "amount_cents", null: false
    t.string "currency", default: "usd", null: false
    t.string "interval", default: "month", null: false
    t.boolean "ai_enabled", default: false, null: false
    t.boolean "active", default: true, null: false
    t.string "stripe_product_id"
    t.string "stripe_price_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_plans_on_slug", unique: true
    t.index ["stripe_price_id"], name: "index_plans_on_stripe_price_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "plan_id"
    t.string "status", default: "trialing", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.datetime "trial_ends_at"
    t.datetime "current_period_end"
    t.boolean "cancel_at_period_end", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_subscriptions_on_company_id", unique: true
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_customer_id"], name: "index_subscriptions_on_stripe_customer_id", unique: true
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name", null: false
    t.string "document_number", null: false
    t.integer "address_zip_code", null: false
    t.string "address_street", null: false
    t.integer "address_number", null: false
    t.string "address_city", null: false
    t.string "address_complement"
    t.string "address_state", null: false
    t.integer "access", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "companies", "users"
  add_foreign_key "host_units", "companies"
  add_foreign_key "lifecycle_events", "companies"
  add_foreign_key "lifecycle_events", "host_units"
  add_foreign_key "lifecycle_events", "parts"
  add_foreign_key "parts", "companies"
  add_foreign_key "parts", "host_units"
  add_foreign_key "parts", "part_type_references"
  add_foreign_key "subscriptions", "companies"
  add_foreign_key "subscriptions", "plans"
end
