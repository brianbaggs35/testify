class SearchController < ApplicationController
  def index
    @query = params[:q]&.strip
    @results = {}
    
    if @query.present?
      # Search across all entities
      @results[:test_cases] = search_test_cases(@query)
      @results[:test_suites] = search_test_suites(@query)
      @results[:test_runs] = search_test_runs(@query)
      @results[:junit_uploads] = search_junit_uploads(@query)
      
      # Calculate total results
      @total_results = @results.values.map(&:count).sum
    else
      @total_results = 0
    end
  end

  private

  def search_test_cases(query)
    TestCase.where(
      "title ILIKE ? OR description ILIKE ? OR steps ILIKE ? OR expected_result ILIKE ?",
      "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%"
    ).limit(20)
  end

  def search_test_suites(query)
    TestSuite.where(
      "name ILIKE ? OR description ILIKE ?",
      "%#{query}%", "%#{query}%"
    ).limit(20)
  end

  def search_test_runs(query)
    TestRun.where(
      "name ILIKE ? OR notes ILIKE ?",
      "%#{query}%", "%#{query}%"
    ).includes(:test_suite).limit(20)
  end

  def search_junit_uploads(query)
    JunitUpload.where(
      "filename ILIKE ? OR project_name ILIKE ?",
      "%#{query}%", "%#{query}%"
    ).limit(20)
  end
end