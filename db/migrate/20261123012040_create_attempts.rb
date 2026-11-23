class CreateAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :attempts do |t|
      t.references :player, null: false, index: false, foreign_key: { on_delete: :restrict }
      t.references :cryptic, null: false, index: false, foreign_key: { on_delete: :restrict }
      t.string :status, null: false
      t.string :difficulty, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :guesses_count, null: false, default: 0
      t.integer :hints_used, null: false, default: 0
      t.integer :elapsed_seconds
      t.integer :points, null: false, default: 0

      t.timestamps

      t.check_constraint "status IN ('assigned','in_progress','solved','given_up','failed')", name: "chk_attempts_status"
      t.check_constraint "difficulty IN ('facil','medio','avanzado')", name: "chk_attempts_difficulty"
      t.check_constraint "finished_at IS NULL OR finished_at >= started_at", name: "chk_attempts_finished_after_started"
      t.check_constraint "guesses_count BETWEEN 0 AND 5", name: "chk_attempts_guesses_count"
      t.check_constraint "hints_used BETWEEN 0 AND 4", name: "chk_attempts_hints_used"
      t.check_constraint "elapsed_seconds IS NULL OR elapsed_seconds >= 0", name: "chk_attempts_elapsed_seconds"
      t.check_constraint "(status = 'solved' AND points >= 10) OR (status <> 'solved' AND points = 0)", name: "chk_attempts_points"

      t.index [ :player_id, :cryptic_id ], unique: true
      t.index :player_id, unique: true, where: "status IN ('assigned','in_progress')", name: "index_attempts_one_open_per_player"
      t.index [ :status, :finished_at ]
      t.index [ :cryptic_id, :status ]
      t.index [ :player_id, :status ]
    end
  end
end
