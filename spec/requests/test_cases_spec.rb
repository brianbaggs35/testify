require 'rails_helper'

RSpec.describe "TestCases", type: :request do
  describe "GET /test_cases" do
    it "returns success" do
      get test_cases_path
      expect(response).to have_http_status(:success)
    end

    it "filters by status" do
      create(:test_case, status: 'Active')
      create(:test_case, status: 'Inactive')
      
      get test_cases_path, params: { status: 'Active' }
      expect(response).to have_http_status(:success)
    end

    it "filters by priority" do
      create(:test_case, priority: 'High')
      create(:test_case, priority: 'Low')
      
      get test_cases_path, params: { priority: 'High' }
      expect(response).to have_http_status(:success)
    end

    it "searches by title and description" do
      create(:test_case, title: 'Login test', description: 'Test user login')
      create(:test_case, title: 'Registration test', description: 'Test user registration')
      
      get test_cases_path, params: { search: 'login' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /test_cases/:id" do
    let(:test_case) { create(:test_case) }

    it "returns success for HTML" do
      get test_case_path(test_case)
      expect(response).to have_http_status(:success)
    end

    it "returns JSON for AJAX requests" do
      get test_case_path(test_case), headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('application/json')
    end
  end

  describe "GET /test_cases/new" do
    it "returns success" do
      get new_test_case_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /test_cases" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          title: 'Test Case Title',
          description: 'Test case description',
          priority: 'Medium',
          status: 'Active'
        }
      end

      it "creates a new test case" do
        expect {
          post test_cases_path, params: { test_case: valid_attributes }
        }.to change(TestCase, :count).by(1)
      end

      it "redirects to the created test case" do
        post test_cases_path, params: { test_case: valid_attributes }
        expect(response).to redirect_to(TestCase.last)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          title: '',
          description: '',
          priority: 'Invalid',
          status: 'Invalid'
        }
      end

      it "does not create a new test case" do
        expect {
          post test_cases_path, params: { test_case: invalid_attributes }
        }.not_to change(TestCase, :count)
      end

      it "returns unprocessable_entity status" do
        post test_cases_path, params: { test_case: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /test_cases/:id/edit" do
    let(:test_case) { create(:test_case) }

    it "returns success" do
      get edit_test_case_path(test_case)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /test_cases/:id" do
    let(:test_case) { create(:test_case) }

    context "with valid parameters" do
      let(:new_attributes) do
        {
          title: 'Updated Test Case Title',
          priority: 'High'
        }
      end

      it "updates the test case" do
        patch test_case_path(test_case), params: { test_case: new_attributes }
        test_case.reload
        expect(test_case.title).to eq('Updated Test Case Title')
        expect(test_case.priority).to eq('High')
      end

      it "redirects to the test case" do
        patch test_case_path(test_case), params: { test_case: new_attributes }
        expect(response).to redirect_to(test_case)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          title: '',
          priority: 'Invalid'
        }
      end

      it "returns unprocessable_entity status" do
        patch test_case_path(test_case), params: { test_case: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /test_cases/:id" do
    let!(:test_case) { create(:test_case) }

    it "deletes the test case" do
      expect {
        delete test_case_path(test_case)
      }.to change(TestCase, :count).by(-1)
    end

    it "redirects to test cases list" do
      delete test_case_path(test_case)
      expect(response).to redirect_to(test_cases_path)
    end
  end
end
