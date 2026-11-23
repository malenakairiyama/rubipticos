class CreateSyncLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_logs do |t|
      t.references :user, null: true, foreign_key: { on_delete: :restrict }
      t.string :status, null: false
      t.string :source_url, null: false
      t.string :version
      t.integer :created_count, null: false, default: 0
      t.integer :updated_count, null: false, default: 0
      t.integer :deactivated_count, null: false, default: 0
      t.integer :rejected_count, null: false, default: 0
      t.json :rejections, null: false, default: []
      t.text :error_message

      t.timestamps

      t.check_constraint "status IN ('success','no_changes','failed')", name: "chk_sync_logs_status"
      t.check_constraint "created_count >= 0", name: "chk_sync_logs_created_count"
      t.check_constraint "updated_count >= 0", name: "chk_sync_logs_updated_count"
      t.check_constraint "deactivated_count >= 0", name: "chk_sync_logs_deactivated_count"
      t.check_constraint "rejected_count >= 0", name: "chk_sync_logs_rejected_count"
      t.check_constraint "json_valid(rejections) AND json_type(rejections) = 'array'", name: "chk_sync_logs_rejections_array"

      t.index [ :status, :source_url, :created_at ]
    end
  end
end
