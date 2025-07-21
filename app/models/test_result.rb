class TestResult < ApplicationRecord
  belongs_to :test_run
  belongs_to :test_case

  validates :status, presence: true, inclusion: { in: %w[Pending Passed Failed Blocked] }

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(executed_at: :desc) }

  def executed?
    executed_at.present?
  end
end
