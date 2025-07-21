FactoryBot.define do
  factory :test_case do
    sequence(:title) { |n| "Test Case #{n}" }
    description { "This is a test case description that explains what the test is supposed to do." }
    steps { "1. Open the application\n2. Navigate to login page\n3. Enter credentials\n4. Click login button\n5. Verify successful login" }
    priority { %w[Low Medium High Critical].sample }
    status { %w[Active Inactive Draft].sample }
  end
end
