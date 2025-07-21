class TestRunsController < ApplicationController
  before_action :set_test_run, only: [ :show, :edit, :update, :destroy, :execute_test ]

  def index
    @test_runs = TestRun.includes(:test_suite, :test_results).recent
  end

  def show
    @test_results = @test_run.test_results.includes(:test_case)
  end

  def new
    @test_run = TestRun.new
    @test_suites = TestSuite.all

    if params[:test_suite_id]
      @test_run.test_suite_id = params[:test_suite_id]
    end
  end

  def create
    @test_run = TestRun.new(test_run_params)

    if @test_run.save
      # Create test results for all test cases in the suite
      @test_run.test_suite.test_cases.each do |test_case|
        @test_run.test_results.create!(
          test_case: test_case,
          status: "Pending"
        )
      end

      redirect_to @test_run, notice: "Test run was successfully created."
    else
      @test_suites = TestSuite.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @test_run.update(test_run_params)
      redirect_to @test_run, notice: "Test run was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @test_run.destroy
    redirect_to test_runs_url, notice: "Test run was successfully deleted."
  end

  def execute_test
    test_result = @test_run.test_results.find(params[:test_result_id])

    test_result.update!(
      status: params[:status],
      notes: params[:notes],
      executed_at: Time.current
    )

    # Update test run status if all tests are complete
    if @test_run.test_results.where(status: "Pending").empty?
      @test_run.update!(status: "Completed")
    elsif @test_run.test_results.where.not(status: "Pending").any?
      @test_run.update!(status: "In_Progress")
    end

    redirect_to @test_run, notice: "Test result updated successfully."
  end

  private

  def set_test_run
    @test_run = TestRun.find(params[:id])
  end

  def test_run_params
    params.require(:test_run).permit(:name, :test_suite_id, :status)
  end
end
