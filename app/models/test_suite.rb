class TestSuite < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true

  # Associations
  has_many :test_suite_test_cases, -> { order(:position) }, dependent: :destroy
  has_many :test_cases, through: :test_suite_test_cases
  has_many :test_runs, dependent: :destroy

  def test_case_count
    test_cases.count
  end

  def add_test_case(test_case, position = nil)
    position ||= test_suite_test_cases.maximum(:position).to_i + 1
    test_suite_test_cases.create!(test_case: test_case, position: position)
  end

  def remove_test_case(test_case)
    test_suite_test_cases.find_by(test_case: test_case)&.destroy
  end
end
