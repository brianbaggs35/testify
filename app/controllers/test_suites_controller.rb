class TestSuitesController < ApplicationController
  before_action :set_test_suite, only: [ :show, :edit, :update, :destroy, :add_test_case, :remove_test_case ]

  def index
    @test_suites = TestSuite.includes(:test_cases).all
  end

  def show
    @test_cases = @test_suite.test_cases.includes(:test_suite_test_cases)
    @available_test_cases = TestCase.active.where.not(id: @test_suite.test_case_ids)
  end

  def new
    @test_suite = TestSuite.new
  end

  def create
    @test_suite = TestSuite.new(test_suite_params)

    if @test_suite.save
      redirect_to @test_suite, notice: "Test suite was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @test_suite.update(test_suite_params)
      redirect_to @test_suite, notice: "Test suite was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @test_suite.destroy
    redirect_to test_suites_url, notice: "Test suite was successfully deleted."
  end

  def add_test_case
    test_case = TestCase.find(params[:test_case_id])
    @test_suite.add_test_case(test_case)
    redirect_to @test_suite, notice: "Test case was added to the suite."
  rescue ActiveRecord::RecordInvalid
    redirect_to @test_suite, alert: "Test case is already in this suite."
  end

  def remove_test_case
    test_case = TestCase.find(params[:test_case_id])
    @test_suite.remove_test_case(test_case)
    redirect_to @test_suite, notice: "Test case was removed from the suite."
  end

  private

  def set_test_suite
    @test_suite = TestSuite.find(params[:id])
  end

  def test_suite_params
    params.require(:test_suite).permit(:name, :description)
  end
end
