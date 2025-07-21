require 'rails_helper'

RSpec.describe TestSuite, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      test_suite = build(:test_suite)
      expect(test_suite).to be_valid
    end

    it 'is valid without a description' do
      test_suite = build(:test_suite, description: nil)
      expect(test_suite).to be_valid
    end
  end

  describe 'associations' do
    it 'has many test_suite_test_cases' do
      association = described_class.reflect_on_association(:test_suite_test_cases)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has many test_cases through test_suite_test_cases' do
      association = described_class.reflect_on_association(:test_cases)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :test_suite_test_cases
    end

    it 'has many test_runs' do
      association = described_class.reflect_on_association(:test_runs)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe 'factory' do
    it 'creates a valid test suite' do
      test_suite = create(:test_suite)
      expect(test_suite).to be_persisted
      expect(test_suite).to be_valid
    end
  end
end
