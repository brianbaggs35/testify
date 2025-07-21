FactoryBot.define do
  factory :junit_upload do
    sequence(:filename) { |n| "test-results-#{n}.xml" }
    file_size { rand(1000..10000000) }
    status { %w[Pending Parsed Error].sample }
    uploaded_at { Time.current }

    trait :parsed do
      status { 'Parsed' }
    end

    trait :with_test_results do
      after(:create) do |upload|
        create_list(:junit_test_result, 5, junit_upload: upload)
      end
    end
  end
end
