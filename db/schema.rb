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

ActiveRecord::Schema.define(version: 20170203060326) do

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

  create_table "gidro", id: false, force: :cascade do |t|
    t.string "Дата",       limit: 60,  null: false
    t.string "Телеграмма", limit: 350, null: false
  end

  create_table "komplekt", primary_key: "ID", force: :cascade do |t|
    t.string "Наименование", limit: 50
    t.string "Модель",       limit: 155
    t.string "Формуляр",     limit: 15
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

  create_table "task", primary_key: "Номер", force: :cascade do |t|
    t.string "Срок",            limit: 50
    t.string "Дата_выполнения", limit: 50
    t.string "Задача",          limit: 150
    t.string "Статус",          limit: 20
    t.string "Примечание",      limit: 500
    t.string "Ответственный",   limit: 45
    t.string "Поручитель",      limit: 45
  end

end
