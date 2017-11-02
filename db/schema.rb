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

ActiveRecord::Schema.define(version: 20171102054625) do

  create_table "agro", id: false, force: :cascade do |t|
    t.string "Дата",       limit: 60,  null: false
    t.string "Телеграмма", limit: 650, null: false
  end

  create_table "agro_observations", force: :cascade do |t|
    t.string   "telegram_type", limit: 255,   default: "ЩЭАГЯ", null: false
    t.integer  "station_id",    limit: 4,                       null: false
    t.date     "date_dev",                                      null: false
    t.integer  "day_obs",       limit: 4,                       null: false
    t.integer  "month_obs",     limit: 4,                       null: false
    t.integer  "telegram_num",  limit: 4,     default: 1,       null: false
    t.text     "telegram",      limit: 65535,                   null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.string   "request_uuid",    limit: 255
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "bulletins", force: :cascade do |t|
    t.date     "report_date"
    t.string   "curr_number",          limit: 255
    t.string   "synoptic1",            limit: 255
    t.string   "synoptic2",            limit: 255
    t.text     "storm",                limit: 65535
    t.text     "forecast_day",         limit: 65535
    t.text     "forecast_period",      limit: 65535
    t.text     "forecast_advice",      limit: 65535
    t.text     "forecast_orientation", limit: 65535
    t.text     "forecast_sea_day",     limit: 65535
    t.text     "forecast_sea_period",  limit: 65535
    t.text     "meteo_data",           limit: 65535
    t.text     "agro_day_review",      limit: 65535
    t.text     "climate_data",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "duty_synoptic",        limit: 255
    t.text     "forecast_day_city",    limit: 65535
    t.boolean  "summer",                             default: false
    t.string   "bulletin_type",        limit: 255,   default: "daily"
    t.integer  "storm_hour",           limit: 4,     default: 0
    t.integer  "storm_minute",         limit: 4,     default: 0
    t.string   "picture",              limit: 255
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "code",       limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "concentrations", force: :cascade do |t|
    t.integer  "city_id",      limit: 4
    t.integer  "site_id",      limit: 4
    t.integer  "year",         limit: 4
    t.integer  "month",        limit: 4
    t.integer  "substance_id", limit: 4
    t.float    "value_w0",     limit: 24
    t.integer  "number_w0",    limit: 4
    t.float    "value_wN",     limit: 24
    t.integer  "number_wN",    limit: 4
    t.float    "value_wE",     limit: 24
    t.integer  "number_wE",    limit: 4
    t.float    "value_wS",     limit: 24
    t.integer  "number_wS",    limit: 4
    t.float    "value_wW",     limit: 24
    t.integer  "number_wW",    limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "gidro", id: false, force: :cascade do |t|
    t.string "Дата",       limit: 60,  null: false
    t.string "Телеграмма", limit: 350, null: false
  end

  create_table "komplekt", primary_key: "ID", force: :cascade do |t|
    t.string "Наименование", limit: 50
    t.string "Модель",       limit: 155
    t.string "Формуляр",     limit: 15
  end

  create_table "materials", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "unit",       limit: 255
    t.float    "pdksr",      limit: 24
    t.float    "pdkmax",     limit: 24
    t.float    "vesmn",      limit: 24
    t.float    "klop",       limit: 24
    t.float    "imax",       limit: 24
    t.integer  "v",          limit: 4
    t.float    "grad",       limit: 24
    t.integer  "point",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "active"
  end

  create_table "measurements", force: :cascade do |t|
    t.integer  "post_id",             limit: 4
    t.date     "date"
    t.integer  "term",                limit: 4
    t.string   "rhumb",               limit: 255
    t.integer  "wind_direction",      limit: 4
    t.integer  "wind_speed",          limit: 4
    t.decimal  "temperature",                     precision: 4, scale: 1
    t.integer  "phenomena",           limit: 4
    t.integer  "relative_humidity",   limit: 4
    t.decimal  "partial_pressure",                precision: 4, scale: 1
    t.integer  "atmosphere_pressure", limit: 4
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "measurements", ["date", "term", "post_id"], name: "index_measurements_on_date_and_term_and_post_id", unique: true, using: :btree

  create_table "pollution_values", force: :cascade do |t|
    t.integer  "measurement_id", limit: 4
    t.integer  "material_id",    limit: 4
    t.float    "value",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "city_id",          limit: 4
    t.integer  "site_type_id",     limit: 4
    t.string   "name",             limit: 255
    t.integer  "substances_num",   limit: 4
    t.integer  "coordinates",      limit: 4
    t.integer  "coordinates_sign", limit: 4
    t.integer  "vd",               limit: 4
    t.integer  "height",           limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "active"
  end

  create_table "reestr", force: :cascade do |t|
    t.string "Наименнование", limit: 155
    t.string "Формуляр",      limit: 12
    t.string "Инвентарный",   limit: 45
    t.string "Кабинет",       limit: 15
    t.string "Ответственный", limit: 195
  end

  create_table "sea_observations", force: :cascade do |t|
    t.date     "date_dev",               null: false
    t.integer  "term",       limit: 4,   null: false
    t.integer  "day_obs",    limit: 4,   null: false
    t.integer  "station_id", limit: 4,   null: false
    t.string   "telegram",   limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

