require 'rails_helper'

RSpec.describe 'Groupdate functionality', type: :system do
  context 'when groupdate gem is available' do
    it 'should provide group_by_day method on ActiveRecord models' do
      # Skip this test if groupdate is not available
      skip 'groupdate gem not available' unless defined?(Groupdate)
      
      # Test that the method exists on TestResult
      expect(TestResult).to respond_to(:group_by_day)
      
      # Test that the method exists on JunitTestResult  
      expect(JunitTestResult).to respond_to(:group_by_day)
      
      # Test that the method exists on TestRun
      expect(TestRun).to respond_to(:group_by_day)
    end
  end

  context 'DashboardController#index' do
    it 'should be able to call group_by_day without NoMethodError' do
      skip 'groupdate gem not available' unless defined?(Groupdate)
      
      # This should not raise NoMethodError when groupdate is installed
      expect { TestResult.group_by_day(:created_at, last: 7) }.not_to raise_error(NoMethodError)
    end
  end
end