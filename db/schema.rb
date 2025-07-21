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

ActiveRecord::Schema[8.0].define(version: 2025_07_20_235527) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "junit_test_results", force: :cascade do |t|
    t.bigint "junit_upload_id", null: false
    t.string "test_name"
    t.string "class_name"
    t.string "status"
    t.text "failure_message"
    t.decimal "execution_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["junit_upload_id"], name: "index_junit_test_results_on_junit_upload_id"
  end

  create_table "junit_uploads", force: :cascade do |t|
    t.string "filename"
    t.integer "file_size"
    t.string "status"
    t.datetime "uploaded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_cases", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "steps"
    t.string "priority"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_results", force: :cascade do |t|
    t.bigint "test_run_id", null: false
    t.bigint "test_case_id", null: false
    t.string "status"
    t.text "notes"
    t.datetime "executed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_case_id"], name: "index_test_results_on_test_case_id"
    t.index ["test_run_id"], name: "index_test_results_on_test_run_id"
  end

  create_table "test_runs", force: :cascade do |t|
    t.string "name"
    t.bigint "test_suite_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_suite_id"], name: "index_test_runs_on_test_suite_id"
  end

  create_table "test_suite_test_cases", force: :cascade do |t|
    t.bigint "test_suite_id", null: false
    t.bigint "test_case_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_case_id"], name: "index_test_suite_test_cases_on_test_case_id"
    t.index ["test_suite_id"], name: "index_test_suite_test_cases_on_test_suite_id"
  end

  create_table "test_suites", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "junit_test_results", "junit_uploads"
  add_foreign_key "test_results", "test_cases"
  add_foreign_key "test_results", "test_runs"
  add_foreign_key "test_runs", "test_suites"
  add_foreign_key "test_suite_test_cases", "test_cases"
  add_foreign_key "test_suite_test_cases", "test_suites"
end
