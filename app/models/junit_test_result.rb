class JunitTestResult < ApplicationRecord
  belongs_to :junit_upload

  validates :test_name, presence: true
  validates :status, presence: true, inclusion: { in: %w[passed failed error skipped] }

  scope :by_status, ->(status) { where(status: status) }
  scope :failed_or_error, -> { where(status: %w[failed error]) }

  def execution_time_human
    return "N/A" if execution_time.nil?
    if execution_time < 1
      "#{(execution_time * 1000).round(0)}ms"
    else
      "#{execution_time.round(2)}s"
    end
  end
end
