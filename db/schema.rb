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

ActiveRecord::Schema.define(version: 2021_06_09_100543) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cr_access_data", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "gender"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "phone_number"
    t.date "date_of_birth"
    t.string "prepmod_patient_id"
    t.string "vaccination_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_cr_access_data_on_created_at"
    t.date "second_dose_reminder_date"
    t.datetime "reminder_sent_at"
    t.date "second_dose_date"
  end

  create_table "cr_access_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cr_access_data_id"
    t.uuid "cr_group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "pending"
    t.string "access_level", default: "anyone"
    t.index ["cr_access_data_id", "cr_group_id"], name: "index_cr_access_groups_on_cr_access_data_id_and_cr_group_id", unique: true
    t.index ["cr_access_data_id"], name: "index_cr_access_groups_on_cr_access_data_id"
    t.index ["cr_group_id", "cr_access_data_id"], name: "index_cr_access_groups_on_cr_group_id_and_cr_access_data_id", unique: true
    t.index ["cr_group_id"], name: "index_cr_access_groups_on_cr_group_id"
    t.index ["created_at"], name: "index_cr_access_groups_on_created_at"
  end

  create_table "cr_data_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cr_access_data_id"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "pending"
    t.boolean "primary", default: false
    t.string "data_type"
    t.index ["cr_access_data_id", "user_id"], name: "index_cr_data_users_on_cr_access_data_id_and_user_id", unique: true
    t.index ["cr_access_data_id"], name: "index_cr_data_users_on_cr_access_data_id"
    t.index ["created_at"], name: "index_cr_data_users_on_created_at"
    t.index ["status", "data_type"], name: "index_cr_data_users_on_status_and_data_type"
    t.index ["user_id", "cr_access_data_id"], name: "index_cr_data_users_on_user_id_and_cr_access_data_id", unique: true
    t.index ["user_id"], name: "index_cr_data_users_on_user_id"
  end

  create_table "cr_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "group_type"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_cr_groups_on_created_at"
    t.index ["user_id"], name: "index_cr_groups_on_user_id"
  end

  create_table "fv_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "fv_codable_type"
    t.uuid "fv_codable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_fv_codes_on_created_at"
    t.index ["fv_codable_type", "fv_codable_id"], name: "index_fv_codes_on_fv_codable"
  end

  create_table "qr_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "codeable_type"
    t.uuid "codeable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["codeable_type", "codeable_id"], name: "index_qr_codes_on_codeable"
    t.index ["created_at"], name: "index_qr_codes_on_created_at"
  end

  create_table "share_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "recipient_id"
    t.string "data"
    t.text "vaccination_record_ids", default: [], array: true
    t.string "status", default: "pending"
    t.string "request_type"
    t.string "relationship"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "accepted_at"
    t.index ["recipient_id"], name: "index_share_requests_on_recipient_id"
    t.index ["user_id"], name: "index_share_requests_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.string "two_fa_code"
    t.datetime "two_fa_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vaccination_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "clinic_name"
    t.string "clinic_location"
    t.string "dose_volume"
    t.string "dose_volume_units"
    t.string "external_id"
    t.string "lot_number"
    t.string "manufacturer_name"
    t.string "reaction"
    t.string "route"
    t.string "site"
    t.datetime "vaccination_date"
    t.string "vaccine_name"
    t.uuid "cr_access_data_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "vaccine_expiration_date"
    t.index ["cr_access_data_id"], name: "index_vaccination_records_on_cr_access_data_id"
    t.index ["created_at"], name: "index_vaccination_records_on_created_at"
  end

  create_table "vaccination_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vaccination_record_id"
    t.uuid "user_id"
    t.string "relation_ship"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_vaccination_users_on_created_at"
    t.index ["user_id", "vaccination_record_id"], name: "index_vaccination_users_on_user_id_and_vaccination_record_id", unique: true
    t.index ["user_id"], name: "index_vaccination_users_on_user_id"
    t.index ["vaccination_record_id", "user_id"], name: "index_vaccination_users_on_vaccination_record_id_and_user_id", unique: true
    t.index ["vaccination_record_id"], name: "index_vaccination_users_on_vaccination_record_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
