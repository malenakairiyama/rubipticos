# Una partida completa. Los hasta 5 intentos de respuesta se cuentan en guesses_count.
class Attempt < ApplicationRecord
  OPEN_STATUSES = %w[assigned in_progress].freeze

  belongs_to :player
  belongs_to :cryptic

  enum :status, {
    assigned: "assigned", in_progress: "in_progress", solved: "solved",
    given_up: "given_up", failed: "failed"
  }, validate: true
  enum :difficulty, Cryptic::DIFFICULTIES, validate: true, prefix: true

  scope :open, -> { where(status: OPEN_STATUSES) }
  scope :finished, -> { where(status: %w[solved given_up failed]) }

  validates :status, :difficulty, presence: true
  validates :cryptic_id, uniqueness: { scope: :player_id }
  validates :player_id, uniqueness: { conditions: -> { where(status: OPEN_STATUSES) } },
                        if: -> { status.in?(OPEN_STATUSES) }
  validates :finished_at, comparison: { greater_than_or_equal_to: :started_at },
                          if: -> { finished_at && started_at }
  validates :guesses_count, numericality: { only_integer: true, in: 0..5 }
  validates :hints_used, numericality: { only_integer: true, in: 0..4 }
  validates :elapsed_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :points, numericality: { only_integer: true }
  validate :points_match_status

  private

  def points_match_status
    return if points.nil?

    if solved?
      errors.add(:points, :greater_than_or_equal_to, count: 10) if points < 10
    elsif points != 0
      errors.add(:points, :equal_to, count: 0)
    end
  end
end
