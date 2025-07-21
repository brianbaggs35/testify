class TestRun < ApplicationRecord
  belongs_to :test_suite

  validates :name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: %w[Pending In_Progress Completed] }

  # Associations
  has_many :test_results, dependent: :destroy

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }

  def passed_count
    test_results.where(status: "Passed").count
  end

  def failed_count
    test_results.where(status: "Failed").count
  end

  def blocked_count
    test_results.where(status: "Blocked").count
  end

  def pending_count
    test_results.where(status: "Pending").count
  end

  def total_count
    test_results.count
  end

  def pass_rate
    return 0 if total_count.zero?
    (passed_count.to_f / total_count * 100).round(1)
  end

  def progress_percentage
    return 0 if test_suite.test_case_count.zero?
    (total_count.to_f / test_suite.test_case_count * 100).round(1)
  end
end
