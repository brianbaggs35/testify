class TestSuiteTestCase < ApplicationRecord
  belongs_to :test_suite
  belongs_to :test_case

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :test_case_id, uniqueness: { scope: :test_suite_id }

  scope :ordered, -> { order(:position) }
end
