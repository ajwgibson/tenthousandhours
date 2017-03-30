# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170330175343) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "projects", force: :cascade do |t|
    t.string   "typeform_id"
    t.string   "organisation_type",                     null: false
    t.string   "organisation_name",                     null: false
    t.string   "contact_name"
    t.string   "contact_role"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "project_1_summary"
    t.string   "project_1_information"
    t.boolean  "project_1_under_18"
    t.string   "project_2_summary"
    t.string   "project_2_information"
    t.boolean  "project_2_under_18"
    t.string   "project_3_summary"
    t.string   "project_3_information"
    t.boolean  "project_3_under_18"
    t.boolean  "any_week",              default: true
    t.boolean  "july_3",                default: false
    t.boolean  "july_10",               default: false
    t.boolean  "july_17",               default: false
    t.boolean  "july_24",               default: false
    t.boolean  "evenings",              default: false
    t.boolean  "saturday",              default: false
    t.string   "notes"
    t.datetime "submitted_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "deleted_at"
  end

  add_index "projects", ["deleted_at"], name: "index_projects_on_deleted_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
