require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #index' do
    context 'when groupdate gem is available' do
      before do
        # Skip if groupdate is not available
        skip 'groupdate gem not available' unless defined?(Groupdate)
      end

      it 'should load dashboard without NoMethodError for group_by_day' do
        expect { get :index }.not_to raise_error(NoMethodError, /undefined method.*group_by_day/)
      end

      it 'should assign manual_test_trend using group_by_day' do
        get :index
        expect(assigns(:manual_test_trend)).to be_a(Hash)
      end

      it 'should assign automated_test_trend using group_by_day' do
        get :index
        expect(assigns(:automated_test_trend)).to be_a(Hash)
      end
    end

    context 'when groupdate gem is not available' do
      before do
        # Only run this test if groupdate is actually missing
        skip 'groupdate gem is available' if defined?(Groupdate)
      end

      it 'should raise NoMethodError for group_by_day' do
        expect { get :index }.to raise_error(NoMethodError, /undefined method.*group_by_day/)
      end
    end
  end
end