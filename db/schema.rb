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

ActiveRecord::Schema[8.1].define(version: 2026_11_23_012041) do
  create_table "attempts", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "cryptic_id", null: false
    t.string "status", null: false
    t.string "difficulty", null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "guesses_count", default: 0, null: false
    t.integer "hints_used", default: 0, null: false
    t.integer "elapsed_seconds"
    t.integer "points", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cryptic_id", "status"], name: "index_attempts_on_cryptic_id_and_status"
    t.index ["player_id", "cryptic_id"], name: "index_attempts_on_player_id_and_cryptic_id", unique: true
    t.index ["player_id", "status"], name: "index_attempts_on_player_id_and_status"
    t.index ["player_id"], name: "index_attempts_one_open_per_player", unique: true, where: "status IN ('assigned','in_progress')"
    t.index ["status", "finished_at"], name: "index_attempts_on_status_and_finished_at"
    t.check_constraint "(status = 'solved' AND points >= 10) OR (status <> 'solved' AND points = 0)", name: "chk_attempts_points"
    t.check_constraint "difficulty IN ('facil','medio','avanzado')", name: "chk_attempts_difficulty"
    t.check_constraint "elapsed_seconds IS NULL OR elapsed_seconds >= 0", name: "chk_attempts_elapsed_seconds"
    t.check_constraint "finished_at IS NULL OR finished_at >= started_at", name: "chk_attempts_finished_after_started"
    t.check_constraint "guesses_count BETWEEN 0 AND 5", name: "chk_attempts_guesses_count"
    t.check_constraint "hints_used BETWEEN 0 AND 4", name: "chk_attempts_hints_used"
    t.check_constraint "status IN ('assigned','in_progress','solved','given_up','failed')", name: "chk_attempts_status"
  end

  create_table "cryptics", force: :cascade do |t|
    t.string "source_id", null: false
    t.text "statement", null: false
    t.string "answer", null: false
    t.string "enumeration", null: false
    t.json "definitions", default: [], null: false
    t.json "indicators", default: [], null: false
    t.json "material", default: [], null: false
    t.string "cryptic_type", null: false
    t.string "difficulty", null: false
    t.text "hint"
    t.text "explanation"
    t.string "author"
    t.boolean "active", default: true, null: false
    t.datetime "deactivated_at"
    t.boolean "deactivated_by_sync", default: false, null: false
    t.string "source_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author"], name: "index_cryptics_on_author"
    t.index ["cryptic_type"], name: "index_cryptics_on_cryptic_type"
    t.index ["difficulty", "active"], name: "index_cryptics_on_difficulty_and_active"
    t.index ["source_id"], name: "index_cryptics_on_source_id", unique: true
    t.check_constraint "cryptic_type IN ('oculta','anagrama','inversion','charada','doble_definicion','iniciales','finales','supresion','sustitucion','homofono','contenedor','simbolos','combinada')", name: "chk_cryptics_cryptic_type"
    t.check_constraint "difficulty IN ('facil','medio','avanzado')", name: "chk_cryptics_difficulty"
    t.check_constraint "json_valid(definitions) AND json_type(definitions) = 'array'", name: "chk_cryptics_definitions_array"
    t.check_constraint "json_valid(indicators) AND json_type(indicators) = 'array'", name: "chk_cryptics_indicators_array"
    t.check_constraint "json_valid(material) AND json_type(material) = 'array'", name: "chk_cryptics_material_array"
    t.check_constraint "length(trim(answer)) > 0", name: "chk_cryptics_answer_not_blank"
    t.check_constraint "length(trim(statement)) > 0", name: "chk_cryptics_statement_not_blank"
  end

  create_table "game_settings", force: :cascade do |t|
    t.integer "hidden_points", default: 100, null: false
    t.integer "anagram_points", default: 100, null: false
    t.integer "reversal_points", default: 100, null: false
    t.integer "charade_points", default: 100, null: false
    t.integer "double_definition_points", default: 100, null: false
    t.integer "initials_points", default: 100, null: false
    t.integer "finals_points", default: 100, null: false
    t.integer "deletion_points", default: 100, null: false
    t.integer "substitution_points", default: 100, null: false
    t.integer "homophone_points", default: 100, null: false
    t.integer "container_points", default: 100, null: false
    t.integer "symbols_points", default: 100, null: false
    t.integer "combined_points", default: 100, null: false
    t.decimal "easy_multiplier", precision: 4, scale: 2, default: "1.0", null: false
    t.decimal "medium_multiplier", precision: 4, scale: 2, default: "2.0", null: false
    t.decimal "hard_multiplier", precision: 4, scale: 2, default: "3.0", null: false
    t.string "source_url", null: false
    t.text "welcome_text"
    t.datetime "leaderboard_reset_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "anagram_points BETWEEN 10 AND 1000", name: "chk_game_settings_anagram_points"
    t.check_constraint "charade_points BETWEEN 10 AND 1000", name: "chk_game_settings_charade_points"
    t.check_constraint "combined_points BETWEEN 10 AND 1000", name: "chk_game_settings_combined_points"
    t.check_constraint "container_points BETWEEN 10 AND 1000", name: "chk_game_settings_container_points"
    t.check_constraint "deletion_points BETWEEN 10 AND 1000", name: "chk_game_settings_deletion_points"
    t.check_constraint "double_definition_points BETWEEN 10 AND 1000", name: "chk_game_settings_double_definition_points"
    t.check_constraint "easy_multiplier > 0 AND easy_multiplier <= 5", name: "chk_game_settings_easy_multiplier"
    t.check_constraint "finals_points BETWEEN 10 AND 1000", name: "chk_game_settings_finals_points"
    t.check_constraint "hard_multiplier > 0 AND hard_multiplier <= 5", name: "chk_game_settings_hard_multiplier"
    t.check_constraint "hidden_points BETWEEN 10 AND 1000", name: "chk_game_settings_hidden_points"
    t.check_constraint "homophone_points BETWEEN 10 AND 1000", name: "chk_game_settings_homophone_points"
    t.check_constraint "id = 1", name: "chk_game_settings_singleton"
    t.check_constraint "initials_points BETWEEN 10 AND 1000", name: "chk_game_settings_initials_points"
    t.check_constraint "medium_multiplier > 0 AND medium_multiplier <= 5", name: "chk_game_settings_medium_multiplier"
    t.check_constraint "reversal_points BETWEEN 10 AND 1000", name: "chk_game_settings_reversal_points"
    t.check_constraint "substitution_points BETWEEN 10 AND 1000", name: "chk_game_settings_substitution_points"
    t.check_constraint "symbols_points BETWEEN 10 AND 1000", name: "chk_game_settings_symbols_points"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.string "name_key", null: false
    t.string "token_digest", null: false
    t.integer "current_streak", default: 0, null: false
    t.integer "best_streak", default: 0, null: false
    t.date "last_solved_on"
    t.datetime "blocked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_key"], name: "index_players_on_name_key", unique: true
    t.index ["token_digest"], name: "index_players_on_token_digest", unique: true
    t.check_constraint "best_streak >= 0", name: "chk_players_best_streak"
    t.check_constraint "current_streak >= 0", name: "chk_players_current_streak"
    t.check_constraint "length(name) BETWEEN 3 AND 20 AND name = trim(name)", name: "chk_players_name"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sync_logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "status", null: false
    t.string "source_url", null: false
    t.string "version"
    t.integer "created_count", default: 0, null: false
    t.integer "updated_count", default: 0, null: false
    t.integer "deactivated_count", default: 0, null: false
    t.integer "rejected_count", default: 0, null: false
    t.json "rejections", default: [], null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "source_url", "created_at"], name: "index_sync_logs_on_status_and_source_url_and_created_at"
    t.index ["user_id"], name: "index_sync_logs_on_user_id"
    t.check_constraint "created_count >= 0", name: "chk_sync_logs_created_count"
    t.check_constraint "deactivated_count >= 0", name: "chk_sync_logs_deactivated_count"
    t.check_constraint "json_valid(rejections) AND json_type(rejections) = 'array'", name: "chk_sync_logs_rejections_array"
    t.check_constraint "rejected_count >= 0", name: "chk_sync_logs_rejected_count"
    t.check_constraint "status IN ('success','no_changes','failed')", name: "chk_sync_logs_status"
    t.check_constraint "updated_count >= 0", name: "chk_sync_logs_updated_count"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "role", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.check_constraint "role IN ('admin','score_editor')", name: "chk_users_role"
  end

  add_foreign_key "attempts", "cryptics", on_delete: :restrict
  add_foreign_key "attempts", "players", on_delete: :restrict
  add_foreign_key "sessions", "users", on_delete: :cascade
  add_foreign_key "sync_logs", "users", on_delete: :restrict
end
