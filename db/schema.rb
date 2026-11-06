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

ActiveRecord::Schema[8.1].define(version: 2026_11_06_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.string "phone_number"
    t.integer "user_id"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "reachouts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "contact_id"
    t.string "frequency"
    t.date "last_reachout_sent"
    t.string "start_date"
    t.string "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "topic"
    t.datetime "next_send_at"
    t.index ["contact_id"], name: "index_reachouts_on_contact_id"
    t.index ["next_send_at"], name: "index_reachouts_on_next_send_at"
    t.index ["user_id"], name: "index_reachouts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.integer "session_version", default: 0, null: false
    t.datetime "password_reset_sent_at"
  end
end
