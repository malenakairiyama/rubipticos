# Singleton: una sola fila con id = 1.
class GameSetting < ApplicationRecord
  POINT_COLUMNS = Cryptic::CRYPTIC_TYPES.keys.map { |key| :"#{key}_points" }.freeze
  MULTIPLIER_COLUMNS = Cryptic::DIFFICULTIES.keys.map { |key| :"#{key}_multiplier" }.freeze

  attribute :id, :integer, default: 1

  validates :id, inclusion: { in: [ 1 ] }
  validates(*POINT_COLUMNS, numericality: { only_integer: true, in: 10..1000 })
  validates(*MULTIPLIER_COLUMNS, numericality: { greater_than: 0, less_than_or_equal_to: 5 })
  validates :source_url, presence: true
end
