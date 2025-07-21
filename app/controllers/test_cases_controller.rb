class TestCasesController < ApplicationController
  before_action :set_test_case, only: [ :show, :edit, :update, :destroy ]

  def index
    @test_cases = TestCase.all
    @test_cases = @test_cases.by_priority(params[:priority]) if params[:priority].present?
    @test_cases = @test_cases.where(status: params[:status]) if params[:status].present?
    @test_cases = @test_cases.where("title ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    @test_cases = @test_cases.order(:created_at)
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @test_case }
    end
  end

  def new
    @test_case = TestCase.new
  end

  def create
    @test_case = TestCase.new(test_case_params)

    if @test_case.save
      redirect_to @test_case, notice: "Test case was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @test_case.update(test_case_params)
      redirect_to @test_case, notice: "Test case was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @test_case.destroy
    redirect_to test_cases_url, notice: "Test case was successfully deleted."
  end

  private

  def set_test_case
    @test_case = TestCase.find(params[:id])
  end

  def test_case_params
    params.require(:test_case).permit(:title, :description, :steps, :priority, :status)
  end
end
