class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :sync_logs, dependent: :restrict_with_error

  enum :role, { admin: "admin", score_editor: "score_editor" }, validate: true

  scope :active, -> { where(active: true) }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :role, presence: true
  validates :active, inclusion: { in: [ true, false ] }
end
