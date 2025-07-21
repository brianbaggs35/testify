class DashboardController < ApplicationController
  def index
    # Manual Testing Statistics
    @total_test_cases = TestCase.count
    @active_test_cases = TestCase.where(status: "Active").count
    @priority_counts = TestCase.group(:priority).count
    @recent_test_cases = TestCase.order(created_at: :desc).limit(5)

    @total_test_suites = TestSuite.count
    @recent_test_suites = TestSuite.order(created_at: :desc).limit(3)

    @total_test_runs = TestRun.count
    @active_test_runs = TestRun.where(status: [ "Pending", "In_Progress" ]).count
    @completed_test_runs = TestRun.where(status: "Completed").count
    @recent_test_runs = TestRun.includes(:test_suite).order(created_at: :desc).limit(3)

    @total_test_results = TestResult.count
    @passed_tests = TestResult.where(status: "Passed").count
    @failed_tests = TestResult.where(status: "Failed").count
    @pending_tests = TestResult.where(status: "Pending").count

    executed_results = TestResult.where.not(status: "Pending").count
    @overall_pass_rate = executed_results > 0 ? (@passed_tests.to_f / executed_results * 100).round(1) : 0

    # Automated Testing Statistics
    @total_junit_uploads = JunitUpload.count
    @parsed_junit_uploads = JunitUpload.where(status: "Parsed").count
    @error_junit_uploads = JunitUpload.where(status: "Error").count
    @recent_junit_uploads = JunitUpload.order(uploaded_at: :desc).limit(5)

    # Automated test results aggregation
    @total_automated_tests = JunitTestResult.count
    @passed_automated_tests = JunitTestResult.where(status: "passed").count
    @failed_automated_tests = JunitTestResult.where(status: "failed").count
    @error_automated_tests = JunitTestResult.where(status: "error").count
    @skipped_automated_tests = JunitTestResult.where(status: "skipped").count
    
    @automated_pass_rate = @total_automated_tests > 0 ? 
      (@passed_automated_tests.to_f / @total_automated_tests * 100).round(1) : 0

    # Calculate test trends for charts
    @manual_test_trend = TestResult.group_by_day(:created_at, last: 7).count
    @automated_test_trend = JunitTestResult.joins(:junit_upload)
                                         .group_by_day('junit_uploads.uploaded_at', last: 7)
                                         .count

    # Test case priority distribution
    @priority_distribution = TestCase.group(:priority).count
    
    # Recent activity
    @recent_activity = []
    
    # Add recent junit uploads
    @recent_junit_uploads.each do |upload|
      @recent_activity << {
        type: 'junit_upload',
        title: "JUnit XML uploaded: #{upload.filename}",
        time: upload.uploaded_at,
        status: upload.status,
        link: junit_upload_path(upload)
      }
    end
    
    # Add recent test runs
    @recent_test_runs.each do |run|
      @recent_activity << {
        type: 'test_run',
        title: "Test run: #{run.name}",
        time: run.created_at,
        status: run.status,
        link: test_run_path(run)
      }
    end
    
    # Sort by time
    @recent_activity.sort_by! { |activity| activity[:time] }.reverse!
    @recent_activity = @recent_activity.first(10)
  end
end
