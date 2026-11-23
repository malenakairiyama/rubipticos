class CreateCryptics < ActiveRecord::Migration[8.1]
  def change
    create_table :cryptics do |t|
      t.string :source_id, null: false
      t.text :statement, null: false
      t.string :answer, null: false
      t.string :enumeration, null: false
      t.json :definitions, null: false, default: []
      t.json :indicators, null: false, default: []
      t.json :material, null: false, default: []
      t.string :cryptic_type, null: false
      t.string :difficulty, null: false
      t.text :hint
      t.text :explanation
      t.string :author
      t.boolean :active, null: false, default: true
      t.datetime :deactivated_at
      t.boolean :deactivated_by_sync, null: false, default: false
      t.string :source_digest

      t.timestamps

      t.check_constraint "length(trim(statement)) > 0", name: "chk_cryptics_statement_not_blank"
      t.check_constraint "length(trim(answer)) > 0", name: "chk_cryptics_answer_not_blank"
      t.check_constraint "json_valid(definitions) AND json_type(definitions) = 'array'", name: "chk_cryptics_definitions_array"
      t.check_constraint "json_valid(indicators) AND json_type(indicators) = 'array'", name: "chk_cryptics_indicators_array"
      t.check_constraint "json_valid(material) AND json_type(material) = 'array'", name: "chk_cryptics_material_array"
      t.check_constraint "cryptic_type IN ('oculta','anagrama','inversion','charada','doble_definicion','iniciales','finales','supresion','sustitucion','homofono','contenedor','simbolos','combinada')", name: "chk_cryptics_cryptic_type"
      t.check_constraint "difficulty IN ('facil','medio','avanzado')", name: "chk_cryptics_difficulty"

      t.index :source_id, unique: true
      t.index [ :difficulty, :active ]
      t.index :cryptic_type
      t.index :author
    end
  end
end
