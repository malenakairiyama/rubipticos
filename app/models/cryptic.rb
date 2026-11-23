class Cryptic < ApplicationRecord
  # Sensibles: answer y explanation nunca viajan al cliente antes de que termine la partida.

  CRYPTIC_TYPES = {
    hidden: "oculta", anagram: "anagrama", reversal: "inversion", charade: "charada",
    double_definition: "doble_definicion", initials: "iniciales", finals: "finales",
    deletion: "supresion", substitution: "sustitucion", homophone: "homofono",
    container: "contenedor", symbols: "simbolos", combined: "combinada"
  }.freeze
  DIFFICULTIES = { easy: "facil", medium: "medio", hard: "avanzado" }.freeze

  enum :cryptic_type, CRYPTIC_TYPES, validate: true
  enum :difficulty, DIFFICULTIES, validate: true

  has_many :attempts, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }

  validates :source_id, presence: true, uniqueness: true
  validates :statement, :answer, :enumeration, presence: true
  validates :cryptic_type, :difficulty, presence: true
  validates :definitions, :indicators, :material, json_array: true
  validates :active, :deactivated_by_sync, inclusion: { in: [ true, false ] }
end
