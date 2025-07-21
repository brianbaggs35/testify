# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample test cases
TestCase.find_or_create_by(title: "Login with valid credentials") do |tc|
  tc.description = "Verify that users can successfully log in with valid email and password"
  tc.steps = "1. Navigate to login page\n2. Enter valid email address\n3. Enter valid password\n4. Click 'Sign In' button\n5. Verify user is redirected to dashboard"
  tc.priority = "High"
  tc.status = "Active"
end

TestCase.find_or_create_by(title: "Login with invalid credentials") do |tc|
  tc.description = "Verify that users cannot log in with invalid credentials and see appropriate error message"
  tc.steps = "1. Navigate to login page\n2. Enter invalid email or password\n3. Click 'Sign In' button\n4. Verify error message is displayed\n5. Verify user remains on login page"
  tc.priority = "Medium"
  tc.status = "Active"
end

TestCase.find_or_create_by(title: "Password reset functionality") do |tc|
  tc.description = "Test the password reset feature for registered users"
  tc.steps = "1. Navigate to login page\n2. Click 'Forgot Password' link\n3. Enter registered email address\n4. Check email for reset link\n5. Click reset link and set new password\n6. Verify login with new password works"
  tc.priority = "Medium"
  tc.status = "Active"
end

TestCase.find_or_create_by(title: "User registration validation") do |tc|
  tc.description = "Verify user registration form validates required fields properly"
  tc.steps = "1. Navigate to registration page\n2. Try submitting empty form\n3. Verify validation errors appear\n4. Enter invalid email format\n5. Enter mismatched passwords\n6. Verify all validation messages are clear"
  tc.priority = "High"
  tc.status = "Draft"
end

TestCase.find_or_create_by(title: "API endpoint response time") do |tc|
  tc.description = "Performance test to ensure API endpoints respond within acceptable time limits"
  tc.steps = "1. Send GET request to /api/users endpoint\n2. Measure response time\n3. Verify response time is under 200ms\n4. Repeat test 10 times\n5. Calculate average response time"
  tc.priority = "Low"
  tc.status = "Active"
end

puts "Created #{TestCase.count} test cases"

# Create sample test suites
auth_suite = TestSuite.find_or_create_by(name: "Authentication Test Suite") do |ts|
  ts.description = "Comprehensive testing of user authentication features including login, logout, and password reset functionality."
end

reg_suite = TestSuite.find_or_create_by(name: "User Registration Suite") do |ts|
  ts.description = "Testing suite for user registration flow and validation checks."
end

api_suite = TestSuite.find_or_create_by(name: "API Performance Suite") do |ts|
  ts.description = "Performance testing suite for critical API endpoints."
end

smoke_suite = TestSuite.find_or_create_by(name: "Smoke Test Suite") do |ts|
  ts.description = "Quick validation tests to ensure basic functionality works after deployment."
end

puts "Created #{TestSuite.count} test suites"

# Add test cases to suites
if auth_suite.test_cases.empty?
  login_valid = TestCase.find_by(title: "Login with valid credentials")
  login_invalid = TestCase.find_by(title: "Login with invalid credentials")
  password_reset = TestCase.find_by(title: "Password reset functionality")

  auth_suite.add_test_case(login_valid, 1) if login_valid
  auth_suite.add_test_case(login_invalid, 2) if login_invalid
  auth_suite.add_test_case(password_reset, 3) if password_reset
end

if reg_suite.test_cases.empty?
  user_reg = TestCase.find_by(title: "User registration validation")
  reg_suite.add_test_case(user_reg, 1) if user_reg
end

if api_suite.test_cases.empty?
  api_test = TestCase.find_by(title: "API endpoint response time")
  api_suite.add_test_case(api_test, 1) if api_test
end

if smoke_suite.test_cases.empty?
  login_valid = TestCase.find_by(title: "Login with valid credentials")
  user_reg = TestCase.find_by(title: "User registration validation")
  smoke_suite.add_test_case(login_valid, 1) if login_valid
  smoke_suite.add_test_case(user_reg, 2) if user_reg
end

puts "Added test cases to suites"

# Create sample test runs
auth_run = TestRun.find_or_create_by(name: "Auth Suite - Sprint 24 Testing", test_suite: auth_suite) do |tr|
  tr.status = "Completed"
end

reg_run = TestRun.find_or_create_by(name: "Registration Suite - UAT", test_suite: reg_suite) do |tr|
  tr.status = "In_Progress"
end

smoke_run = TestRun.find_or_create_by(name: "Smoke Tests - Production Deploy", test_suite: smoke_suite) do |tr|
  tr.status = "Pending"
end

puts "Created #{TestRun.count} test runs"

# Create sample test results for completed run
if auth_run.test_results.empty?
  auth_suite.test_cases.each_with_index do |test_case, index|
    status = case index
    when 0 then "Passed"
    when 1 then "Failed"
    when 2 then "Passed"
    else "Pending"
    end

    TestResult.create!(
      test_run: auth_run,
      test_case: test_case,
      status: status,
      notes: status == "Failed" ? "Error message validation not displaying correctly" : "Test executed successfully",
      executed_at: status == "Pending" ? nil : 2.hours.ago
    )
  end
end

# Create sample test results for in-progress run
if reg_run.test_results.empty?
  reg_suite.test_cases.each do |test_case|
    TestResult.create!(
      test_run: reg_run,
      test_case: test_case,
      status: "Pending",
      notes: nil,
      executed_at: nil
    )
  end
end

puts "Created #{TestResult.count} test results"

# Create sample JUnit uploads
junit1 = JunitUpload.find_or_create_by(filename: "unit-tests-results.xml") do |ju|
  ju.file_size = 15432
  ju.status = "Parsed"
  ju.uploaded_at = 1.day.ago
end

junit2 = JunitUpload.find_or_create_by(filename: "integration-tests.xml") do |ju|
  ju.file_size = 8234
  ju.status = "Parsed"
  ju.uploaded_at = 3.hours.ago
end

junit3 = JunitUpload.find_or_create_by(filename: "e2e-test-results.xml") do |ju|
  ju.file_size = 12876
  ju.status = "Pending"
  ju.uploaded_at = 30.minutes.ago
end

puts "Created #{JunitUpload.count} JUnit uploads"

# Create sample JUnit test results
if junit1.junit_test_results.empty?
  [
    { test_name: "testUserLogin", class_name: "com.example.AuthTest", status: "passed", execution_time: 0.123 },
    { test_name: "testUserLogout", class_name: "com.example.AuthTest", status: "passed", execution_time: 0.089 },
    { test_name: "testInvalidPassword", class_name: "com.example.AuthTest", status: "failed", execution_time: 0.156, failure_message: "Expected error message not displayed" },
    { test_name: "testPasswordReset", class_name: "com.example.AuthTest", status: "passed", execution_time: 0.234 },
    { test_name: "testUserRegistration", class_name: "com.example.UserTest", status: "passed", execution_time: 0.345 }
  ].each do |result|
    JunitTestResult.create!(
      junit_upload: junit1,
      test_name: result[:test_name],
      class_name: result[:class_name],
      status: result[:status],
      execution_time: result[:execution_time],
      failure_message: result[:failure_message]
    )
  end
end

if junit2.junit_test_results.empty?
  [
    { test_name: "testDatabaseConnection", class_name: "com.example.IntegrationTest", status: "passed", execution_time: 1.234 },
    { test_name: "testAPIEndpoints", class_name: "com.example.IntegrationTest", status: "passed", execution_time: 2.456 },
    { test_name: "testEmailService", class_name: "com.example.IntegrationTest", status: "error", execution_time: 0.567, failure_message: "SMTP connection timeout" }
  ].each do |result|
    JunitTestResult.create!(
      junit_upload: junit2,
      test_name: result[:test_name],
      class_name: result[:class_name],
      status: result[:status],
      execution_time: result[:execution_time],
      failure_message: result[:failure_message]
    )
  end
end

puts "Created #{JunitTestResult.count} JUnit test results"

puts "\n=== Sample Data Summary ==="
puts "Test Cases: #{TestCase.count}"
puts "Test Suites: #{TestSuite.count}"
puts "Test Runs: #{TestRun.count}"
puts "Test Results: #{TestResult.count}"
puts "JUnit Uploads: #{JunitUpload.count}"
puts "JUnit Test Results: #{JunitTestResult.count}"
