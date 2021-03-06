# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180526160603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "personal_projects", id: :serial, force: :cascade do |t|
    t.date "project_date", null: false
    t.decimal "duration", precision: 2, scale: 1, null: false
    t.integer "volunteer_count", null: false
    t.text "description", null: false
    t.integer "volunteer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_personal_projects_on_deleted_at"
    t.index ["volunteer_id"], name: "index_personal_projects_on_volunteer_id"
  end

  create_table "project_slots", id: :serial, force: :cascade do |t|
    t.date "slot_date", null: false
    t.integer "slot_type", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "extra_volunteers", default: 0, null: false
    t.index ["deleted_at"], name: "index_project_slots_on_deleted_at"
    t.index ["project_id"], name: "index_project_slots_on_project_id"
  end

  create_table "project_slots_volunteers", id: false, force: :cascade do |t|
    t.integer "project_slot_id"
    t.integer "volunteer_id"
    t.index ["project_slot_id"], name: "index_project_slots_volunteers_on_project_slot_id"
    t.index ["volunteer_id"], name: "index_project_slots_volunteers_on_volunteer_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "typeform_id"
    t.string "organisation_type", null: false
    t.string "project_name", null: false
    t.string "contact_name"
    t.string "contact_role"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "activity_1_summary"
    t.string "activity_1_information"
    t.boolean "activity_1_under_18"
    t.string "activity_2_summary"
    t.string "activity_2_information"
    t.boolean "activity_2_under_18"
    t.string "activity_3_summary"
    t.string "activity_3_information"
    t.boolean "activity_3_under_18"
    t.boolean "any_week", default: true
    t.boolean "week_1", default: false
    t.boolean "week_2", default: false
    t.boolean "week_3", default: false
    t.boolean "week_4", default: false
    t.boolean "evenings", default: false
    t.boolean "saturday", default: false
    t.string "notes"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "materials"
    t.integer "adults"
    t.integer "youth"
    t.integer "status", default: 0, null: false
    t.string "summary"
    t.integer "kids"
    t.string "leader"
    t.string "morning_start_time", default: "09:30"
    t.string "afternoon_start_time", default: "14:00"
    t.string "evening_start_time", default: "19:00"
    t.decimal "morning_slot_length", precision: 2, scale: 1, default: "3.0"
    t.decimal "afternoon_slot_length", precision: 2, scale: 1, default: "3.5"
    t.decimal "evening_slot_length", precision: 2, scale: 1, default: "3.0"
    t.index ["deleted_at"], name: "index_projects_on_deleted_at"
  end

  create_table "reminders", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "volunteer_id", null: false
    t.date "reminder_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_reminders_on_project_id"
    t.index ["volunteer_id"], name: "index_reminders_on_volunteer_id"
  end

  create_table "text_messages", id: :serial, force: :cascade do |t|
    t.text "message", null: false
    t.text "recipients", null: false
    t.text "response"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "volunteers", id: :serial, force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "mobile", default: "", null: false
    t.integer "age_category", null: false
    t.text "skills", default: [], null: false, array: true
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "family"
    t.string "mobile_confirmation_code"
    t.string "guardian_name"
    t.string "guardian_contact_number"
    t.integer "extra_adults", default: 0, null: false
    t.integer "extra_youth", default: 0, null: false
    t.integer "extra_children", default: 0, null: false
    t.string "activity_consent_recorded_by"
    t.boolean "can_contact_future", default: false
    t.index ["confirmation_token"], name: "index_volunteers_on_confirmation_token", unique: true
    t.index ["email"], name: "index_volunteers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_volunteers_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_volunteers_on_unlock_token", unique: true
  end

  add_foreign_key "personal_projects", "volunteers"
  add_foreign_key "project_slots", "projects"
  add_foreign_key "reminders", "projects"
  add_foreign_key "reminders", "volunteers"
end
