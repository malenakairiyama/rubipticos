class CreateGameSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :game_settings do |t|
      t.integer :hidden_points, null: false, default: 100
      t.integer :anagram_points, null: false, default: 100
      t.integer :reversal_points, null: false, default: 100
      t.integer :charade_points, null: false, default: 100
      t.integer :double_definition_points, null: false, default: 100
      t.integer :initials_points, null: false, default: 100
      t.integer :finals_points, null: false, default: 100
      t.integer :deletion_points, null: false, default: 100
      t.integer :substitution_points, null: false, default: 100
      t.integer :homophone_points, null: false, default: 100
      t.integer :container_points, null: false, default: 100
      t.integer :symbols_points, null: false, default: 100
      t.integer :combined_points, null: false, default: 100
      t.decimal :easy_multiplier, precision: 4, scale: 2, null: false, default: 1
      t.decimal :medium_multiplier, precision: 4, scale: 2, null: false, default: 2
      t.decimal :hard_multiplier, precision: 4, scale: 2, null: false, default: 3
      t.string :source_url, null: false
      t.text :welcome_text
      t.datetime :leaderboard_reset_at

      t.timestamps

      t.check_constraint "id = 1", name: "chk_game_settings_singleton"
      t.check_constraint "hidden_points BETWEEN 10 AND 1000", name: "chk_game_settings_hidden_points"
      t.check_constraint "anagram_points BETWEEN 10 AND 1000", name: "chk_game_settings_anagram_points"
      t.check_constraint "reversal_points BETWEEN 10 AND 1000", name: "chk_game_settings_reversal_points"
      t.check_constraint "charade_points BETWEEN 10 AND 1000", name: "chk_game_settings_charade_points"
      t.check_constraint "double_definition_points BETWEEN 10 AND 1000", name: "chk_game_settings_double_definition_points"
      t.check_constraint "initials_points BETWEEN 10 AND 1000", name: "chk_game_settings_initials_points"
      t.check_constraint "finals_points BETWEEN 10 AND 1000", name: "chk_game_settings_finals_points"
      t.check_constraint "deletion_points BETWEEN 10 AND 1000", name: "chk_game_settings_deletion_points"
      t.check_constraint "substitution_points BETWEEN 10 AND 1000", name: "chk_game_settings_substitution_points"
      t.check_constraint "homophone_points BETWEEN 10 AND 1000", name: "chk_game_settings_homophone_points"
      t.check_constraint "container_points BETWEEN 10 AND 1000", name: "chk_game_settings_container_points"
      t.check_constraint "symbols_points BETWEEN 10 AND 1000", name: "chk_game_settings_symbols_points"
      t.check_constraint "combined_points BETWEEN 10 AND 1000", name: "chk_game_settings_combined_points"
      t.check_constraint "easy_multiplier > 0 AND easy_multiplier <= 5", name: "chk_game_settings_easy_multiplier"
      t.check_constraint "medium_multiplier > 0 AND medium_multiplier <= 5", name: "chk_game_settings_medium_multiplier"
      t.check_constraint "hard_multiplier > 0 AND hard_multiplier <= 5", name: "chk_game_settings_hard_multiplier"
    end
  end
end
