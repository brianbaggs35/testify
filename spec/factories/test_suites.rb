FactoryBot.define do
  factory :test_suite do
    sequence(:name) { |n| "Test Suite #{n}" }
    description { "This is a comprehensive test suite that covers various testing scenarios." }
  end
end
