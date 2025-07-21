class TestCase < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :priority, presence: true, inclusion: { in: %w[Low Medium High Critical] }
  validates :status, presence: true, inclusion: { in: %w[Active Inactive Draft] }

  # Associations
  has_many :test_suite_test_cases, dependent: :destroy
  has_many :test_suites, through: :test_suite_test_cases
  has_many :test_results, dependent: :destroy

  scope :active, -> { where(status: "Active") }
  scope :by_priority, ->(priority) { where(priority: priority) }
end
