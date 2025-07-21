FactoryBot.define do
  factory :junit_test_result do
    association :junit_upload
    sequence(:test_name) { |n| "testMethod#{n}" }
    sequence(:class_name) { |n| "com.example.TestClass#{n}" }
    status { %w[passed failed error skipped].sample }
    execution_time { rand(0.001..5.0).round(3) }
    failure_message { status == 'passed' ? nil : "Test failed: Expected value but got something else" }
  end
end