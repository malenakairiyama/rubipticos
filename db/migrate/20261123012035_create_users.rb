class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :role, null: false
      t.boolean :active, null: false, default: true

      t.timestamps

      t.check_constraint "role IN ('admin','score_editor')", name: "chk_users_role"
    end
    add_index :users, :email_address, unique: true
  end
end
