class SyncLog < ApplicationRecord
  COUNT_COLUMNS = %i[created_count updated_count deactivated_count rejected_count].freeze

  # user nil = corrida desde db:seed.
  belongs_to :user, optional: true

  enum :status, { success: "success", no_changes: "no_changes", failed: "failed" }, validate: true

  validates :status, :source_url, presence: true
  validates(*COUNT_COLUMNS, numericality: { only_integer: true, greater_than_or_equal_to: 0 })
  validates :rejections, json_array: true
end
