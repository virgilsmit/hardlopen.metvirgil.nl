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

ActiveRecord::Schema[7.1].define(version: 2025_06_25_130751) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "training_session_id", null: false
    t.string "status", default: "0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_attendances_on_status"
    t.index ["training_session_id"], name: "index_attendances_on_training_session_id"
    t.index ["user_id", "training_session_id"], name: "index_attendances_on_user_id_and_training_session_id", unique: true
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

  create_table "group_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.bigint "hoofdtrainer_id"
    t.bigint "medetrainer_id"
    t.index ["hoofdtrainer_id"], name: "index_groups_on_hoofdtrainer_id"
    t.index ["medetrainer_id"], name: "index_groups_on_medetrainer_id"
  end

  create_table "performances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "test_type"
    t.string "value"
    t.date "date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "distance"
    t.index ["user_id"], name: "index_performances_on_user_id"
  end

  create_table "photos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "training_session_id", null: false
    t.string "image"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_session_id"], name: "index_photos_on_training_session_id"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "presences", force: :cascade do |t|
    t.bigint "session_id", null: false
    t.string "name"
    t.bigint "user_id", null: false
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_presences_on_session_id"
    t.index ["user_id"], name: "index_presences_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "name"
    t.float "distance"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "title"
    t.text "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "trainer_name"
    t.date "date"
    t.time "time"
    t.string "training_type"
    t.string "location"
    t.string "trainer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_sessions_on_group_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_statuses_on_name", unique: true
  end

  create_table "training_assignments", force: :cascade do |t|
    t.bigint "training_id", null: false
    t.bigint "user_id", null: false
    t.string "rol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_id"], name: "index_training_assignments_on_training_id"
    t.index ["user_id"], name: "index_training_assignments_on_user_id"
  end

  create_table "training_drills", force: :cascade do |t|
    t.bigint "training_session_id", null: false
    t.bigint "drill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drill_id"], name: "index_training_drills_on_drill_id"
    t.index ["training_session_id"], name: "index_training_drills_on_training_session_id"
  end

  create_table "training_routes", force: :cascade do |t|
    t.bigint "training_session_id", null: false
    t.bigint "route_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_training_routes_on_route_id"
    t.index ["training_session_id"], name: "index_training_routes_on_training_session_id"
  end

  create_table "training_schedules", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.integer "weekday"
    t.time "start_time"
    t.time "end_time"
    t.string "location"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_training_schedules_on_group_id"
  end

  create_table "training_schemas", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "group_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_training_schemas_on_group_id"
    t.index ["user_id"], name: "index_training_schemas_on_user_id"
  end

  create_table "training_sessions", force: :cascade do |t|
    t.date "date"
    t.text "description"
    t.bigint "training_schema_id", null: false
    t.bigint "group_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_training_sessions_on_group_id"
    t.index ["training_schema_id"], name: "index_training_sessions_on_training_schema_id"
    t.index ["user_id"], name: "index_training_sessions_on_user_id"
  end

  create_table "trainings", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_trainings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "phone"
    t.string "emergency_contact"
    t.date "birthday"
    t.text "injury"
    t.boolean "photo_permission"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.bigint "trainer_id"
    t.integer "group_id"
    t.string "status"
    t.string "csv_name"
    t.integer "status_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["trainer_id"], name: "index_users_on_trainer_id"
  end

  create_table "vacations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vacations_on_user_id"
  end

  add_foreign_key "attendances", "training_sessions"
  add_foreign_key "attendances", "users"
  add_foreign_key "clients", "groups"
  add_foreign_key "clients", "users"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "users", column: "hoofdtrainer_id"
  add_foreign_key "groups", "users", column: "medetrainer_id"
  add_foreign_key "performances", "users"
  add_foreign_key "photos", "training_sessions"
  add_foreign_key "photos", "users"
  add_foreign_key "presences", "sessions"
  add_foreign_key "presences", "users"
  add_foreign_key "sessions", "groups"
  add_foreign_key "training_assignments", "trainings"
  add_foreign_key "training_assignments", "users"
  add_foreign_key "training_drills", "drills"
  add_foreign_key "training_drills", "training_sessions"
  add_foreign_key "training_routes", "routes"
  add_foreign_key "training_routes", "training_sessions"
  add_foreign_key "training_schedules", "groups"
  add_foreign_key "training_schemas", "groups"
  add_foreign_key "training_schemas", "users"
  add_foreign_key "training_sessions", "groups"
  add_foreign_key "training_sessions", "training_schemas"
  add_foreign_key "training_sessions", "users"
  add_foreign_key "trainings", "users"
  add_foreign_key "users", "groups"
  add_foreign_key "users", "users", column: "trainer_id"
  add_foreign_key "vacations", "users"
end
