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

ActiveRecord::Schema[8.0].define(version: 2025_09_30_084043) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

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
end
