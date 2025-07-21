class JunitUpload < ApplicationRecord
  validates :filename, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[Pending Parsed Error] }

  # Associations
  has_many :junit_test_results, dependent: :destroy
  has_one_attached :file

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(uploaded_at: :desc) }

  def passed_count
    junit_test_results.where(status: "passed").count
  end

  def failed_count
    junit_test_results.where(status: "failed").count
  end

  def error_count
    junit_test_results.where(status: "error").count
  end

  def skipped_count
    junit_test_results.where(status: "skipped").count
  end

  def total_count
    junit_test_results.count
  end

  def file_size_human
    if file_size < 1024
      "#{file_size} B"
    elsif file_size < 1024 * 1024
      "#{(file_size / 1024.0).round(1)} KB"
    else
      "#{(file_size / (1024.0 * 1024)).round(1)} MB"
    end
  end
end
