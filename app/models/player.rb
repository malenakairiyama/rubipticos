class Player < ApplicationRecord
  has_many :attempts, dependent: :restrict_with_error
  has_many :cryptics, through: :attempts

  scope :visible, -> { where(blocked_at: nil) }

  # name_key se calcula en Ruby: downcase Unicode (unifica Ñ/ñ y vocales con tilde).
  before_validation { self.name_key = name&.downcase }

  validates :name, presence: true, length: { in: 3..20 }
  validate :name_without_surrounding_spaces
  validates :name_key, presence: true, uniqueness: true
  validates :token_digest, presence: true, uniqueness: true
  validates :current_streak, :best_streak, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  private

  def name_without_surrounding_spaces
    errors.add(:name, :surrounding_spaces, message: "no puede empezar ni terminar con espacios") if name && name != name.strip
  end
end
