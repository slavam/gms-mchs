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

ActiveRecord::Schema.define(version: 20170604185010) do

  create_table "agro", id: false, force: :cascade do |t|
    t.string "Дата",       limit: 60,  null: false
    t.string "Телеграмма", limit: 650, null: false
  end

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
  end

  create_table "reestr", force: :cascade do |t|
    t.string "Наименнование", limit: 155
    t.string "Формуляр",      limit: 12
    t.string "Инвентарный",   limit: 45
    t.string "Кабинет",       limit: 15
    t.string "Ответственный", limit: 195
  end

  create_table "sinop", id: false, force: :cascade do |t|
    t.string "Дата",       limit: 65,  null: false
    t.string "Срок",       limit: 7,   null: false
    t.string "Телеграмма", limit: 350, null: false
  end

  create_table "site_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task", primary_key: "Номер", force: :cascade do |t|
    t.string "Срок",            limit: 50
    t.string "Дата_выполнения", limit: 50
    t.string "Задача",          limit: 150
    t.string "Статус",          limit: 20
    t.string "Примечание",      limit: 500
    t.string "Ответственный",   limit: 45
    t.string "Поручитель",      limit: 45
  end

  create_table "users", force: :cascade do |t|
    t.string   "last_name",       limit: 255
    t.string   "first_name",      limit: 255
    t.string   "middle_name",     limit: 255
    t.string   "login",           limit: 255
    t.string   "password_digest", limit: 255
    t.string   "position",        limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "remember_digest", limit: 255
    t.string   "role",            limit: 255
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

end
