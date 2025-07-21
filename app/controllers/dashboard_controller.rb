class DashboardController < ApplicationController
  def index
    # Test Cases Statistics
    @total_test_cases = TestCase.count
    @active_test_cases = TestCase.where(status: "Active").count
    @priority_counts = TestCase.group(:priority).count
    @recent_test_cases = TestCase.order(created_at: :desc).limit(5)

    # Test Suites Statistics
    @total_test_suites = TestSuite.count
    @recent_test_suites = TestSuite.order(created_at: :desc).limit(3)

    # Test Runs Statistics
    @total_test_runs = TestRun.count
    @active_test_runs = TestRun.where(status: [ "Pending", "In_Progress" ]).count
    @completed_test_runs = TestRun.where(status: "Completed").count
    @recent_test_runs = TestRun.includes(:test_suite).order(created_at: :desc).limit(3)

    # Test Results Statistics
    @total_test_results = TestResult.count
    @passed_tests = TestResult.where(status: "Passed").count
    @failed_tests = TestResult.where(status: "Failed").count
    @pending_tests = TestResult.where(status: "Pending").count

    # JUnit Upload Statistics
    @total_junit_uploads = JunitUpload.count
    @parsed_junit_uploads = JunitUpload.where(status: "Parsed").count
    @recent_junit_uploads = JunitUpload.order(uploaded_at: :desc).limit(3)

    # Overall pass rate
    executed_results = TestResult.where.not(status: "Pending").count
    @overall_pass_rate = executed_results > 0 ? (@passed_tests.to_f / executed_results * 100).round(1) : 0
  end
end
