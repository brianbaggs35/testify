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
