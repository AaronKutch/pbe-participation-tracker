# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_20_224636) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "first_name", limit: 50, null: false
    t.string "last_name", limit: 50, null: false
    t.string "email", limit: 128, null: false
    t.string "role", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest", null: false
  end

  create_table "customers_events", id: false, force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "event_id", null: false
    t.index ["customer_id"], name: "index_customers_events_on_customer_id"
    t.index ["event_id"], name: "index_customers_events_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", limit: 50, null: false
    t.text "description"
    t.datetime "date", null: false
    t.string "location", limit: 128
    t.boolean "mandatory"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
