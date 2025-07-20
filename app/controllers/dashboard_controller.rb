class DashboardController < ApplicationController
  def index
    @total_test_cases = TestCase.count
    @active_test_cases = TestCase.where(status: "Active").count
    @priority_counts = TestCase.group(:priority).count
    @recent_test_cases = TestCase.order(created_at: :desc).limit(5)
  end
end
