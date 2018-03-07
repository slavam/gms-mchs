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

ActiveRecord::Schema.define(version: 20180306063448) do

  create_table "agro", id: false, force: :cascade do |t|
    t.string "Дата",       limit: 60,  null: false
    t.string "Телеграмма", limit: 650, null: false
  end

  create_table "agro_crop_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "agro_crops", force: :cascade do |t|
    t.integer  "agro_crop_category_id", limit: 4,   null: false
    t.integer  "code",                  limit: 4
    t.string   "name",                  limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "agro_crops", ["code"], name: "index_agro_crops_on_code", unique: true, using: :btree

  create_table "agro_damages", force: :cascade do |t|
    t.integer  "code",       limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "agro_dec_observations", force: :cascade do |t|
    t.date     "date_dev"
    t.integer  "day_obs",                          limit: 4
    t.integer  "month_obs",                        limit: 4
    t.string   "telegram",                         limit: 255
    t.integer  "station_id",                       limit: 4
    t.integer  "telegram_num",                     limit: 4
    t.integer  "temperature_dec_avg_delta",        limit: 4
    t.decimal  "temperature_dec_avg",                          precision: 5, scale: 1
    t.integer  "temperature_dec_max",              limit: 4
    t.integer  "hot_dec_day_num",                  limit: 4
    t.integer  "temperature_dec_min",              limit: 4
    t.integer  "dry_dec_day_num",                  limit: 4
    t.integer  "temperature_dec_min_soil",         limit: 4
    t.integer  "cold_soil_dec_day_num",            limit: 4
    t.integer  "precipitation_dec",                limit: 4
    t.integer  "wet_dec_day_num",                  limit: 4
    t.integer  "precipitation_dec_percent",        limit: 4
    t.integer  "wind_speed_dec_max",               limit: 4
    t.integer  "wind_speed_dec_max_day_num",       limit: 4
    t.integer  "duster_dec_day_num",               limit: 4
    t.integer  "temperature_dec_max_soil",         limit: 4
    t.integer  "sunshine_duration_dec",            limit: 4
    t.integer  "freezing_dec_day_num",             limit: 4
    t.integer  "temperature_dec_avg_soil10",       limit: 4
    t.integer  "temperature25_soil10_dec_day_num", limit: 4
    t.integer  "dew_dec_day_num",                  limit: 4
    t.integer  "saturation_deficit_dec_avg",       limit: 4
    t.integer  "relative_humidity_dec_avg",        limit: 4
    t.integer  "percipitation_dec_max",            limit: 4
    t.integer  "percipitation5_dec_day_num",       limit: 4
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
  end

  create_table "agro_observations", force: :cascade do |t|
    t.string   "telegram_type",             limit: 255,                           default: "ЩЭАГЯ", null: false
    t.integer  "station_id",                limit: 4,                                               null: false
    t.datetime "date_dev",                                                                          null: false
    t.integer  "day_obs",                   limit: 4,                                               null: false
    t.integer  "month_obs",                 limit: 4,                                               null: false
    t.integer  "telegram_num",              limit: 4,                             default: 1,       null: false
    t.text     "telegram",                  limit: 65535,                                           null: false
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
    t.integer  "temperature_max_12",        limit: 4
    t.decimal  "temperature_avg_24",                      precision: 5, scale: 1
    t.integer  "temperature_min_24",        limit: 4
    t.integer  "temperature_min_soil_24",   limit: 4
    t.integer  "percipitation_24",          limit: 4
    t.integer  "percipitation_type",        limit: 4
    t.integer  "percipitation_12",          limit: 4
    t.integer  "wind_speed_max_24",         limit: 4
    t.integer  "saturation_deficit_max_24", limit: 4
    t.integer  "duration_dew_24",           limit: 4
    t.integer  "dew_intensity_max",         limit: 4
    t.integer  "dew_intensity_8",           limit: 4
    t.integer  "sunshine_duration_24",      limit: 4
    t.integer  "state_top_layer_soil",      limit: 4
    t.integer  "temperature_field_5_16",    limit: 4
    t.integer  "temperature_field_10_16",   limit: 4
    t.integer  "temperature_avg_soil_5",    limit: 4
    t.integer  "temperature_avg_soil_10",   limit: 4
    t.integer  "saturation_deficit_avg_24", limit: 4
    t.integer  "relative_humidity_min_24",  limit: 4
  end

  create_table "agro_phase_categories", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "agro_phases", force: :cascade do |t|
    t.integer  "agro_phase_category_id", limit: 4,   null: false
    t.integer  "code",                   limit: 4
    t.string   "name",                   limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "agro_works", force: :cascade do |t|
    t.integer  "code",       limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
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

  create_table "chem_coefficients", force: :cascade do |t|
    t.integer  "material_id",        limit: 4,                         null: false
    t.integer  "laboratory_id",      limit: 4,                         null: false
    t.decimal  "calibration_factor",           precision: 6, scale: 3
    t.decimal  "aliquot_volume",               precision: 5, scale: 2
    t.decimal  "solution_volume",              precision: 5, scale: 2
    t.decimal  "sample_volume",                precision: 7, scale: 2
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
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

  create_table "crop_conditions", force: :cascade do |t|
    t.integer  "agro_observation_id",    limit: 4
    t.integer  "crop_code",              limit: 4, null: false
    t.integer  "development_phase_1",    limit: 4
    t.integer  "development_phase_2",    limit: 4
    t.integer  "development_phase_3",    limit: 4
    t.integer  "development_phase_4",    limit: 4
    t.integer  "development_phase_5",    limit: 4
    t.integer  "assessment_condition_1", limit: 4
    t.integer  "assessment_condition_2", limit: 4
    t.integer  "assessment_condition_3", limit: 4
    t.integer  "assessment_condition_4", limit: 4
    t.integer  "assessment_condition_5", limit: 4
    t.integer  "agricultural_work_1",    limit: 4
    t.integer  "agricultural_work_2",    limit: 4
    t.integer  "agricultural_work_3",    limit: 4
    t.integer  "agricultural_work_4",    limit: 4
    t.integer  "agricultural_work_5",    limit: 4
    t.integer  "damage_plants_1",        limit: 4
    t.integer  "damage_plants_2",        limit: 4
    t.integer  "damage_plants_3",        limit: 4
    t.integer  "damage_plants_4",        limit: 4
    t.integer  "damage_plants_5",        limit: 4
    t.integer  "damage_volume_1",        limit: 4
    t.integer  "damage_volume_2",        limit: 4
    t.integer  "damage_volume_3",        limit: 4
    t.integer  "damage_volume_4",        limit: 4
    t.integer  "damage_volume_5",        limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "index_weather_1",        limit: 4
    t.integer  "index_weather_2",        limit: 4
    t.integer  "index_weather_3",        limit: 4
    t.integer  "index_weather_4",        limit: 4
    t.integer  "index_weather_5",        limit: 4
  end

  create_table "crop_damages", force: :cascade do |t|
    t.integer  "agro_observation_id",       limit: 4
    t.integer  "crop_code",                 limit: 4, null: false
    t.integer  "height_snow_cover_rail",    limit: 4
    t.integer  "depth_soil_freezing",       limit: 4
    t.integer  "thermometer_index",         limit: 4
    t.integer  "temperature_dec_min_soil3", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "crop_dec_conditions", force: :cascade do |t|
    t.integer  "agro_dec_observation_id",   limit: 4
    t.integer  "crop_code",                 limit: 4
    t.integer  "plot_code",                 limit: 4
    t.integer  "agrotechnology",            limit: 4
    t.integer  "development_phase_1",       limit: 4
    t.integer  "development_phase_2",       limit: 4
    t.integer  "development_phase_3",       limit: 4
    t.integer  "development_phase_4",       limit: 4
    t.integer  "development_phase_5",       limit: 4
    t.integer  "day_phase_1",               limit: 4
    t.integer  "day_phase_2",               limit: 4
    t.integer  "day_phase_3",               limit: 4
    t.integer  "day_phase_4",               limit: 4
    t.integer  "day_phase_5",               limit: 4
    t.integer  "assessment_condition_1",    limit: 4
    t.integer  "assessment_condition_2",    limit: 4
    t.integer  "assessment_condition_3",    limit: 4
    t.integer  "assessment_condition_4",    limit: 4
    t.integer  "assessment_condition_5",    limit: 4
    t.integer  "clogging_weeds",            limit: 4
    t.integer  "height_plants",             limit: 4
    t.integer  "number_plants",             limit: 4
    t.integer  "average_mass",              limit: 4
    t.integer  "agricultural_work_1",       limit: 4
    t.integer  "agricultural_work_2",       limit: 4
    t.integer  "agricultural_work_3",       limit: 4
    t.integer  "agricultural_work_4",       limit: 4
    t.integer  "agricultural_work_5",       limit: 4
    t.integer  "day_work_1",                limit: 4
    t.integer  "day_work_2",                limit: 4
    t.integer  "day_work_3",                limit: 4
    t.integer  "day_work_4",                limit: 4
    t.integer  "day_work_5",                limit: 4
    t.integer  "damage_plants_1",           limit: 4
    t.integer  "damage_plants_2",           limit: 4
    t.integer  "damage_plants_3",           limit: 4
    t.integer  "damage_plants_4",           limit: 4
    t.integer  "damage_plants_5",           limit: 4
    t.integer  "day_damage_1",              limit: 4
    t.integer  "day_damage_2",              limit: 4
    t.integer  "day_damage_3",              limit: 4
    t.integer  "day_damage_4",              limit: 4
    t.integer  "day_damage_5",              limit: 4
    t.integer  "damage_level_1",            limit: 4
    t.integer  "damage_level_2",            limit: 4
    t.integer  "damage_level_3",            limit: 4
    t.integer  "damage_level_4",            limit: 4
    t.integer  "damage_level_5",            limit: 4
    t.integer  "damage_volume_1",           limit: 4
    t.integer  "damage_volume_2",           limit: 4
    t.integer  "damage_volume_3",           limit: 4
    t.integer  "damage_volume_4",           limit: 4
    t.integer  "damage_volume_5",           limit: 4
    t.integer  "damage_space_1",            limit: 4
    t.integer  "damage_space_2",            limit: 4
    t.integer  "damage_space_3",            limit: 4
    t.integer  "damage_space_4",            limit: 4
    t.integer  "damage_space_5",            limit: 4
    t.integer  "number_spicas",             limit: 4
    t.integer  "num_bad_spicas",            limit: 4
    t.integer  "number_stalks",             limit: 4
    t.integer  "stalk_with_spike_num",      limit: 4
    t.integer  "normal_size_potato",        limit: 4
    t.integer  "losses",                    limit: 4
    t.integer  "grain_num",                 limit: 4
    t.integer  "bad_grain_percent",         limit: 4
    t.integer  "bushiness",                 limit: 4
    t.integer  "shoots_inflorescences",     limit: 4
    t.decimal  "grain1000_mass",                      precision: 5, scale: 1
    t.integer  "moisture_reserve_10",       limit: 4
    t.integer  "moisture_reserve_5",        limit: 4
    t.integer  "soil_index",                limit: 4
    t.integer  "moisture_reserve_2",        limit: 4
    t.integer  "moisture_reserve_1",        limit: 4
    t.integer  "temperature_water_2",       limit: 4
    t.integer  "depth_water",               limit: 4
    t.integer  "depth_groundwater",         limit: 4
    t.integer  "depth_thawing_soil",        limit: 4
    t.integer  "depth_soil_wetting",        limit: 4
    t.integer  "height_snow_cover",         limit: 4
    t.integer  "snow_retention",            limit: 4
    t.integer  "snow_cover",                limit: 4
    t.decimal  "snow_cover_density",                  precision: 5, scale: 2
    t.integer  "number_measurements_0",     limit: 4
    t.integer  "number_measurements_3",     limit: 4
    t.integer  "number_measurements_30",    limit: 4
    t.integer  "ice_crust",                 limit: 4
    t.integer  "thickness_ice_cake",        limit: 4
    t.integer  "depth_thawing_soil_2",      limit: 4
    t.integer  "depth_soil_freezing",       limit: 4
    t.integer  "thaw_days",                 limit: 4
    t.integer  "thermometer_index",         limit: 4
    t.integer  "temperature_dec_min_soil3", limit: 4
    t.integer  "height_snow_cover_rail",    limit: 4
    t.integer  "viable_method",             limit: 4
    t.integer  "soil_index_2",              limit: 4
    t.integer  "losses_1",                  limit: 4
    t.integer  "losses_2",                  limit: 4
    t.integer  "losses_3",                  limit: 4
    t.integer  "losses_4",                  limit: 4
    t.integer  "temperature_dead50",        limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
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

  create_table "laboratories", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
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

  create_table "meteo_links", force: :cascade do |t|
    t.string   "name",       limit: 255,                null: false
    t.string   "address",    limit: 255,                null: false
    t.boolean  "is_active",              default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "pollution_values", force: :cascade do |t|
    t.integer  "measurement_id", limit: 4
    t.integer  "material_id",    limit: 4
    t.float    "value",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.float    "concentration",  limit: 24
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "city_id",            limit: 4
    t.integer  "site_type_id",       limit: 4
    t.string   "name",               limit: 255
    t.integer  "substances_num",     limit: 4
    t.integer  "coordinates",        limit: 4
    t.integer  "coordinates_sign",   limit: 4
    t.integer  "vd",                 limit: 4
    t.integer  "height",             limit: 4
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "active"
    t.integer  "laboratory_id",      limit: 4
    t.string   "short_name",         limit: 255
    t.decimal  "sample_volume_dust",             precision: 7, scale: 2
  end

  create_table "reestr", force: :cascade do |t|
    t.string "Наименнование", limit: 155
    t.string "Формуляр",      limit: 12
    t.string "Инвентарный",   limit: 45
    t.string "Кабинет",       limit: 15
    t.string "Ответственный", limit: 195
  end

  create_table "sea_observations", force: :cascade do |t|
    t.datetime "date_dev",               null: false
    t.integer  "term",       limit: 4,   null: false
    t.integer  "day_obs",    limit: 4,   null: false
    t.integer  "station_id", limit: 4,   null: false
    t.string   "telegram",   limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
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

  create_table "stations", force: :cascade do |t|
    t.string  "name", limit: 255
    t.integer "code", limit: 4
  end

  create_table "storm_observations", force: :cascade do |t|
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "telegram_type", limit: 255, default: "ЩЭОЯЮ", null: false
    t.integer  "station_id",    limit: 4,                     null: false
    t.integer  "day_event",     limit: 4,                     null: false
    t.integer  "hour_event",    limit: 4
    t.integer  "minute_event",  limit: 4
    t.string   "telegram",      limit: 255,                   null: false
    t.datetime "telegram_date"
  end

  create_table "synoptic_observations", force: :cascade do |t|
    t.date     "date"
    t.integer  "term",                             limit: 4
    t.string   "telegram",                         limit: 255
    t.integer  "station_id",                       limit: 4
    t.integer  "cloud_base_height",                limit: 4
    t.integer  "visibility_range",                 limit: 4
    t.integer  "cloud_amount_1",                   limit: 4
    t.integer  "wind_direction",                   limit: 4
    t.integer  "wind_speed_avg",                   limit: 4
    t.decimal  "temperature",                                  precision: 5, scale: 1
    t.decimal  "temperature_dew_point",                        precision: 5, scale: 1
    t.decimal  "pressure_at_station_level",                    precision: 6, scale: 1
    t.decimal  "pressure_at_sea_level",                        precision: 6, scale: 1
    t.integer  "pressure_tendency_characteristic", limit: 4
    t.decimal  "pressure_tendency",                            precision: 6, scale: 1
    t.integer  "precipitation_1",                  limit: 4
    t.integer  "precipitation_time_range_1",       limit: 4
    t.integer  "weather_in_term",                  limit: 4
    t.integer  "weather_past_1",                   limit: 4
    t.integer  "weather_past_2",                   limit: 4
    t.integer  "cloud_amount_2",                   limit: 4
    t.integer  "clouds_1",                         limit: 4
    t.integer  "clouds_2",                         limit: 4
    t.integer  "clouds_3",                         limit: 4
    t.decimal  "temperature_dey_max",                          precision: 5, scale: 1
    t.decimal  "temperature_night_min",                        precision: 5, scale: 1
    t.integer  "underlying_surface_сondition",     limit: 4
    t.integer  "snow_cover_height",                limit: 4
    t.decimal  "sunshine_duration",                            precision: 5, scale: 1
    t.integer  "cloud_amount_3",                   limit: 4
    t.integer  "cloud_form",                       limit: 4
    t.integer  "cloud_height",                     limit: 4
    t.string   "weather_data_add",                 limit: 255
    t.integer  "soil_surface_condition_1",         limit: 4
    t.integer  "temperature_soil",                 limit: 4
    t.integer  "soil_surface_condition_2",         limit: 4
    t.decimal  "temperature_soil_min",                         precision: 5, scale: 1
    t.integer  "temperature_2cm_min",              limit: 4
    t.integer  "precipitation_2",                  limit: 4
    t.integer  "precipitation_time_range_2",       limit: 4
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.datetime "observed_at"
  end

  add_index "synoptic_observations", ["date", "term", "station_id"], name: "index_synoptic_observations_on_date_and_term_and_station_id", unique: true, using: :btree

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
