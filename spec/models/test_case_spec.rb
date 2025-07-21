require 'rails_helper'

RSpec.describe TestCase, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      test_case = build(:test_case)
      expect(test_case).to be_valid
    end

    it 'requires a title' do
      test_case = build(:test_case, title: nil)
      expect(test_case).not_to be_valid
      expect(test_case.errors[:title]).to include("can't be blank")
    end

    it 'requires title to be less than 255 characters' do
      test_case = build(:test_case, title: 'a' * 256)
      expect(test_case).not_to be_valid
      expect(test_case.errors[:title]).to include('is too long (maximum is 255 characters)')
    end

    it 'requires a description' do
      test_case = build(:test_case, description: nil)
      expect(test_case).not_to be_valid
      expect(test_case.errors[:description]).to include("can't be blank")
    end

    it 'requires a valid priority' do
      valid_priorities = %w[Low Medium High Critical]
      valid_priorities.each do |priority|
        test_case = build(:test_case, priority: priority)
        expect(test_case).to be_valid
      end

      test_case = build(:test_case, priority: 'Invalid')
      expect(test_case).not_to be_valid
      expect(test_case.errors[:priority]).to include('is not included in the list')
    end

    it 'requires a valid status' do
      valid_statuses = %w[Active Inactive Draft]
      valid_statuses.each do |status|
        test_case = build(:test_case, status: status)
        expect(test_case).to be_valid
      end

      test_case = build(:test_case, status: 'Invalid')
      expect(test_case).not_to be_valid
      expect(test_case.errors[:status]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it 'has many test_suite_test_cases' do
      association = described_class.reflect_on_association(:test_suite_test_cases)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has many test_suites through test_suite_test_cases' do
      association = described_class.reflect_on_association(:test_suites)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :test_suite_test_cases
    end

    it 'has many test_results' do
      association = described_class.reflect_on_association(:test_results)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe 'scopes' do
    before do
      create(:test_case, status: 'Active', priority: 'High')
      create(:test_case, status: 'Inactive', priority: 'Low')
      create(:test_case, status: 'Active', priority: 'Medium')
    end

    describe '.active' do
      it 'returns only active test cases' do
        active_count = TestCase.active.count
        expect(active_count).to eq(2)
        expect(TestCase.active.pluck(:status).uniq).to eq(['Active'])
      end
    end

    describe '.by_priority' do
      it 'returns test cases with the specified priority' do
        high_priority_cases = TestCase.by_priority('High')
        expect(high_priority_cases.count).to eq(1)
        expect(high_priority_cases.first.priority).to eq('High')
      end
    end
  end

  describe 'factory' do
    it 'creates a valid test case' do
      test_case = create(:test_case)
      expect(test_case).to be_persisted
      expect(test_case).to be_valid
    end
  end
end
