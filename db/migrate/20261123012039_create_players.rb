class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.string :name_key, null: false
      t.string :token_digest, null: false
      t.integer :current_streak, null: false, default: 0
      t.integer :best_streak, null: false, default: 0
      t.date :last_solved_on
      t.datetime :blocked_at

      t.timestamps

      t.check_constraint "length(name) BETWEEN 3 AND 20 AND name = trim(name)", name: "chk_players_name"
      t.check_constraint "current_streak >= 0", name: "chk_players_current_streak"
      t.check_constraint "best_streak >= 0", name: "chk_players_best_streak"

      t.index :name_key, unique: true
      t.index :token_digest, unique: true
    end
  end
end
