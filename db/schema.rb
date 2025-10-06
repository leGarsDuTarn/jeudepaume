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

ActiveRecord::Schema[8.0].define(version: 2025_10_06_193616) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "assets_statements", force: :cascade do |t|
    t.date "filed_on", null: false
    t.string "kind", null: false
    t.integer "total_assets_cents"
    t.text "document_url"
    t.text "document_meta"
    t.bigint "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filed_on"], name: "index_assets_statements_on_filed_on"
    t.index ["person_id", "filed_on", "kind"], name: "index_assets_statements_on_person_id_and_filed_on_and_kind", unique: true
    t.index ["person_id"], name: "index_assets_statements_on_person_id"
    t.check_constraint "total_assets_cents IS NULL OR total_assets_cents >= 0", name: "chk_assets_total_nonneg"
  end

  create_table "attendances", force: :cascade do |t|
    t.string "scope", null: false
    t.string "scope_ref"
    t.integer "presence_count", default: 0, null: false
    t.integer "absence_count", default: 0, null: false
    t.decimal "vote_participation_rate", precision: 5, scale: 2
    t.string "source"
    t.bigint "mandate_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mandate_id", "scope", "scope_ref"], name: "index_attendances_on_mandate_id_and_scope_and_scope_ref"
    t.index ["mandate_id"], name: "index_attendances_on_mandate_id"
    t.index ["scope"], name: "index_attendances_on_scope"
    t.check_constraint "absence_count >= 0", name: "chk_attendance_absence_nonneg"
    t.check_constraint "presence_count >= 0", name: "chk_attendance_presence_nonneg"
    t.check_constraint "vote_participation_rate IS NULL OR vote_participation_rate >= 0::numeric AND vote_participation_rate <= 100::numeric", name: "chk_attendance_vote_rate_range"
  end

  create_table "compensations", force: :cascade do |t|
    t.string "kind", null: false
    t.string "label"
    t.integer "amount_gross_cents", default: 0, null: false
    t.string "period"
    t.date "effective_from", null: false
    t.date "effective_to"
    t.string "source"
    t.bigint "mandate_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mandate_id", "effective_from"], name: "index_compensations_on_mandate_id_and_effective_from"
    t.index ["mandate_id", "kind", "label", "effective_from"], name: "uniq_comp_mand_kind_label_from", unique: true
    t.index ["mandate_id"], name: "index_compensations_on_mandate_id"
    t.check_constraint "amount_gross_cents >= 0", name: "chk_compensations_amount_non_negative"
    t.check_constraint "effective_to IS NULL OR effective_to >= effective_from", name: "chk_compensations_chronology"
  end

  create_table "constituencies", force: :cascade do |t|
    t.citext "slug", null: false
    t.string "name", null: false
    t.string "level", null: false
    t.string "insee_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insee_code"], name: "index_constituencies_on_insee_code", unique: true
    t.index ["name", "level"], name: "index_constituencies_on_name_and_level", unique: true
    t.index ["slug"], name: "index_constituencies_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.citext "slug", null: false
    t.string "name", null: false
    t.string "kind", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_institutions_on_kind"
    t.index ["name"], name: "index_institutions_on_name"
    t.index ["slug"], name: "index_institutions_on_slug", unique: true
  end

  create_table "mandates", force: :cascade do |t|
    t.string "role", null: false
    t.string "status"
    t.date "started_on", null: false
    t.date "ended_on"
    t.string "seat_label"
    t.string "source"
    t.bigint "person_id", null: false
    t.bigint "political_group_id"
    t.bigint "institution_id", null: false
    t.bigint "constituency_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["constituency_id"], name: "index_mandates_on_constituency_id"
    t.index ["institution_id"], name: "index_mandates_on_institution_id"
    t.index ["person_id", "institution_id", "started_on"], name: "index_mandates_on_person_id_and_institution_id_and_started_on"
    t.index ["person_id"], name: "index_mandates_on_person_id"
    t.index ["political_group_id"], name: "index_mandates_on_political_group_id"
    t.check_constraint "ended_on IS NULL OR ended_on >= started_on", name: "chk_mandates_chronology"
  end

  create_table "people", force: :cascade do |t|
    t.citext "slug", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "birth_name"
    t.string "full_name"
    t.string "gender"
    t.date "birth_date"
    t.string "birth_place"
    t.string "birth_postal_code"
    t.string "nationality"
    t.text "image_url"
    t.text "image_meta"
    t.text "socials"
    t.text "website"
    t.text "bio"
    t.text "external_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_people_on_slug", unique: true
  end

  create_table "political_groups", force: :cascade do |t|
    t.citext "slug", null: false
    t.string "name", null: false
    t.string "short_name"
    t.string "color_hex"
    t.bigint "institution_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institution_id"], name: "index_political_groups_on_institution_id"
    t.index ["name", "institution_id"], name: "index_political_groups_on_name_and_institution_id", unique: true
    t.index ["name"], name: "index_political_groups_on_name"
    t.index ["short_name"], name: "index_political_groups_on_short_name"
    t.index ["slug"], name: "index_political_groups_on_slug", unique: true
  end

  create_table "sources", force: :cascade do |t|
    t.citext "slug", null: false
    t.string "title"
    t.text "url", null: false
    t.string "kind"
    t.string "checksum"
    t.datetime "fetched_at"
    t.jsonb "extra", default: {}, null: false
    t.string "sourceable_type", null: false
    t.bigint "sourceable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checksum"], name: "index_sources_on_checksum"
    t.index ["slug"], name: "index_sources_on_slug", unique: true
    t.index ["sourceable_type", "sourceable_id"], name: "index_sources_on_sourceable"
    t.index ["url"], name: "index_sources_on_url"
  end

  create_table "users", force: :cascade do |t|
    t.citext "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.citext "user_name", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

  add_foreign_key "assets_statements", "people"
  add_foreign_key "attendances", "mandates"
  add_foreign_key "compensations", "mandates"
  add_foreign_key "mandates", "constituencies"
  add_foreign_key "mandates", "institutions"
  add_foreign_key "mandates", "people"
  add_foreign_key "mandates", "political_groups"
  add_foreign_key "political_groups", "institutions"
end
