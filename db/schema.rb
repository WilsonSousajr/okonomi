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

ActiveRecord::Schema[8.1].define(version: 2026_09_28_120400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "acceptance_criteria", force: :cascade do |t|
    t.text "action", null: false
    t.text "context", null: false
    t.datetime "created_at", null: false
    t.text "outcome", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_story_id", null: false
    t.index ["user_story_id"], name: "index_acceptance_criteria_on_user_story_id"
  end

  create_table "backlogs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "ends_on"
    t.text "goal"
    t.string "kind", null: false
    t.string "name", null: false
    t.bigint "project_id", null: false
    t.date "starts_on"
    t.datetime "updated_at", null: false
    t.index ["project_id", "id"], name: "index_backlogs_on_project_id_and_id", unique: true
    t.index ["project_id"], name: "index_backlogs_one_product_per_project", unique: true, where: "((kind)::text = 'product'::text)"
    t.check_constraint "ends_on >= starts_on", name: "backlogs_ends_after_start"
    t.check_constraint "kind::text = ANY (ARRAY['product'::character varying, 'sprint'::character varying]::text[])", name: "backlogs_kind_domain"
  end

  create_table "epics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "project_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "id"], name: "index_epics_on_project_id_and_id", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_stories", force: :cascade do |t|
    t.text "action", null: false
    t.bigint "backlog_id", null: false
    t.text "benefit", null: false
    t.datetime "created_at", null: false
    t.bigint "epic_id"
    t.string "moscow", limit: 1
    t.bigint "project_id", null: false
    t.integer "rice_confidence"
    t.integer "rice_effort"
    t.decimal "rice_impact", precision: 3, scale: 2
    t.integer "rice_reach"
    t.text "role", null: false
    t.integer "story_points"
    t.datetime "updated_at", null: false
    t.index ["backlog_id"], name: "index_user_stories_on_backlog_id"
    t.index ["epic_id"], name: "index_user_stories_on_epic_id"
    t.index ["project_id"], name: "index_user_stories_on_project_id"
    t.check_constraint "moscow::text = ANY (ARRAY['M'::character varying, 'S'::character varying, 'C'::character varying, 'W'::character varying]::text[])", name: "user_stories_moscow_domain"
    t.check_constraint "rice_confidence = ANY (ARRAY[100, 80, 50])", name: "user_stories_rice_confidence_domain"
    t.check_constraint "rice_effort = ANY (ARRAY[0, 1, 2, 3, 5, 8, 13, 21, 34, 55])", name: "user_stories_rice_effort_domain"
    t.check_constraint "rice_impact = ANY (ARRAY[3::numeric, 2::numeric, 1::numeric, 0.5, 0.25])", name: "user_stories_rice_impact_domain"
    t.check_constraint "rice_reach >= 0", name: "user_stories_rice_reach_domain"
    t.check_constraint "story_points = ANY (ARRAY[0, 1, 2, 3, 5, 8, 13, 21, 34, 55])", name: "user_stories_story_points_domain"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "acceptance_criteria", "user_stories"
  add_foreign_key "backlogs", "projects"
  add_foreign_key "epics", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_stories", "backlogs", column: ["project_id", "backlog_id"], primary_key: ["project_id", "id"]
  add_foreign_key "user_stories", "epics", column: ["project_id", "epic_id"], primary_key: ["project_id", "id"]
  add_foreign_key "user_stories", "projects"
end
