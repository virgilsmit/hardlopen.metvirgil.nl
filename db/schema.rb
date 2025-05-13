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

ActiveRecord::Schema[7.1].define(version: 2025_05_09_190854) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "training_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_id"], name: "index_attendances_on_training_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_clients_on_group_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "drills", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "video_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.string "trainer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "performances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "test_type"
    t.string "value"
    t.date "date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_performances_on_user_id"
  end

  create_table "photos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "training_id", null: false
    t.string "image"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_id"], name: "index_photos_on_training_id"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "name"
    t.float "distance"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "training_drills", force: :cascade do |t|
    t.bigint "training_id", null: false
    t.bigint "drill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drill_id"], name: "index_training_drills_on_drill_id"
    t.index ["training_id"], name: "index_training_drills_on_training_id"
  end

  create_table "training_routes", force: :cascade do |t|
    t.bigint "training_id", null: false
    t.bigint "route_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_training_routes_on_route_id"
    t.index ["training_id"], name: "index_training_routes_on_training_id"
  end

  create_table "trainings", force: :cascade do |t|
    t.date "date"
    t.string "location"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "emergency_contact"
    t.date "birthday"
    t.text "injury"
    t.boolean "photo_permission"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vacations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vacations_on_user_id"
  end

  add_foreign_key "attendances", "trainings"
  add_foreign_key "attendances", "users"
  add_foreign_key "clients", "groups"
  add_foreign_key "clients", "users"
  add_foreign_key "performances", "users"
  add_foreign_key "photos", "trainings"
  add_foreign_key "photos", "users"
  add_foreign_key "training_drills", "drills"
  add_foreign_key "training_drills", "trainings"
  add_foreign_key "training_routes", "routes"
  add_foreign_key "training_routes", "trainings"
  add_foreign_key "vacations", "users"
end
