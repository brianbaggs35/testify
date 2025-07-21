class ReportsController < ApplicationController
  def automated_index
    @junit_uploads = JunitUpload.includes(:junit_test_results).recent
  end

  def automated_show
    @junit_upload = JunitUpload.find(params[:id])
    @junit_test_results = @junit_upload.junit_test_results
    
    # Calculate metrics for the report
    @total_tests = @junit_test_results.count
    @passed_tests = @junit_test_results.where(status: 'passed').count
    @failed_tests = @junit_test_results.where(status: 'failed').count
    @error_tests = @junit_test_results.where(status: 'error').count
    @skipped_tests = @junit_test_results.where(status: 'skipped').count
    
    @pass_rate = @total_tests > 0 ? (@passed_tests.to_f / @total_tests * 100).round(2) : 0
    @total_execution_time = @junit_test_results.sum(:execution_time).round(3)
  end

  def automated_pdf
    @junit_upload = JunitUpload.find(params[:id])
    @junit_test_results = @junit_upload.junit_test_results
    
    # Calculate metrics for the report
    @total_tests = @junit_test_results.count
    @passed_tests = @junit_test_results.where(status: 'passed').count
    @failed_tests = @junit_test_results.where(status: 'failed').count
    @error_tests = @junit_test_results.where(status: 'error').count
    @skipped_tests = @junit_test_results.where(status: 'skipped').count
    
    @pass_rate = @total_tests > 0 ? (@passed_tests.to_f / @total_tests * 100).round(2) : 0
    @total_execution_time = @junit_test_results.sum(:execution_time).round(3)

    generate_automated_pdf
  end

  def manual_index
    @test_suites = TestSuite.includes(:test_cases, :test_runs)
  end

  def manual_show
    @test_suite = TestSuite.find(params[:id])
    @test_cases = @test_suite.test_cases.includes(:test_results)
    @test_runs = @test_suite.test_runs.includes(:test_results)
    
    # Calculate metrics for the report
    @total_test_cases = @test_cases.count
    @total_test_runs = @test_runs.count
    
    if @test_runs.any?
      latest_run = @test_runs.order(:created_at).last
      @latest_results = latest_run.test_results.includes(:test_case)
      @passed_in_latest = @latest_results.where(status: 'passed').count
      @failed_in_latest = @latest_results.where(status: 'failed').count
      @pending_in_latest = @latest_results.where(status: 'pending').count
    else
      @latest_results = []
      @passed_in_latest = 0
      @failed_in_latest = 0
      @pending_in_latest = 0
    end
  end

  def manual_pdf
    @test_suite = TestSuite.find(params[:id])
    @test_cases = @test_suite.test_cases.includes(:test_results)
    @test_runs = @test_suite.test_runs.includes(:test_results)
    
    # Calculate metrics for the report
    @total_test_cases = @test_cases.count
    @total_test_runs = @test_runs.count
    
    if @test_runs.any?
      latest_run = @test_runs.order(:created_at).last
      @latest_results = latest_run.test_results.includes(:test_case)
      @passed_in_latest = @latest_results.where(status: 'passed').count
      @failed_in_latest = @latest_results.where(status: 'failed').count
      @pending_in_latest = @latest_results.where(status: 'pending').count
    else
      @latest_results = []
      @passed_in_latest = 0
      @failed_in_latest = 0
      @pending_in_latest = 0
    end

    generate_manual_pdf
  end

  private

  def generate_automated_pdf
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
    
    # Header
    pdf.text "Automated Test Report", size: 24, style: :bold, align: :center
    pdf.text "#{@junit_upload.filename}", size: 16, align: :center
    pdf.text "Generated on #{Time.current.strftime('%B %d, %Y at %I:%M %p')}", size: 12, align: :center
    pdf.move_down 30

    # Summary section
    pdf.text "Test Execution Summary", size: 18, style: :bold
    pdf.move_down 10
    
    summary_data = [
      ["Total Tests", @total_tests.to_s],
      ["Passed", "#{@passed_tests} (#{(@passed_tests.to_f / @total_tests * 100).round(1)}%)" ],
      ["Failed", "#{@failed_tests} (#{(@failed_tests.to_f / @total_tests * 100).round(1)}%)"],
      ["Errors", "#{@error_tests} (#{(@error_tests.to_f / @total_tests * 100).round(1)}%)"],
      ["Skipped", "#{@skipped_tests} (#{(@skipped_tests.to_f / @total_tests * 100).round(1)}%)"],
      ["Total Execution Time", "#{@total_execution_time}s"],
      ["Pass Rate", "#{@pass_rate}%"]
    ]
    
    pdf.table(summary_data, 
      header: false,
      width: pdf.bounds.width,
      cell_style: { borders: [:top, :bottom], padding: 8 }
    )
    
    pdf.move_down 30

    # Failed tests section
    if @failed_tests > 0 || @error_tests > 0
      pdf.text "Failed and Error Tests", size: 18, style: :bold
      pdf.move_down 10
      
      failed_and_error_tests = @junit_test_results.where(status: ['failed', 'error'])
      
      if failed_and_error_tests.any?
        failed_data = [["Test Name", "Class", "Status", "Error Message"]]
        failed_and_error_tests.each do |test|
          failed_data << [
            test.test_name,
            test.class_name,
            test.status.capitalize,
            test.failure_message&.truncate(100) || "N/A"
          ]
        end
        
        pdf.table(failed_data,
          header: true,
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: 4 }
        )
      end
    end

    send_data pdf.render, 
      filename: "automated_test_report_#{@junit_upload.id}_#{Date.current}.pdf",
      type: 'application/pdf',
      disposition: 'attachment'
  end

  def generate_manual_pdf
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
    
    # Header
    pdf.text "Manual Test Report", size: 24, style: :bold, align: :center
    pdf.text "#{@test_suite.name}", size: 16, align: :center
    pdf.text "Generated on #{Time.current.strftime('%B %d, %Y at %I:%M %p')}", size: 12, align: :center
    pdf.move_down 30

    # Summary section
    pdf.text "Test Suite Summary", size: 18, style: :bold
    pdf.move_down 10
    
    summary_data = [
      ["Test Suite", @test_suite.name],
      ["Description", @test_suite.description || "N/A"],
      ["Total Test Cases", @total_test_cases.to_s],
      ["Total Test Runs", @total_test_runs.to_s]
    ]
    
    if @test_runs.any?
      summary_data += [
        ["Latest Run - Passed", @passed_in_latest.to_s],
        ["Latest Run - Failed", @failed_in_latest.to_s],
        ["Latest Run - Pending", @pending_in_latest.to_s]
      ]
    end
    
    pdf.table(summary_data, 
      header: false,
      width: pdf.bounds.width,
      cell_style: { borders: [:top, :bottom], padding: 8 }
    )
    
    pdf.move_down 30

    # Test cases section
    if @test_cases.any?
      pdf.text "Test Cases", size: 18, style: :bold
      pdf.move_down 10
      
      test_case_data = [["Title", "Priority", "Status", "Description"]]
      @test_cases.each do |test_case|
        test_case_data << [
          test_case.title,
          test_case.priority || "N/A",
          test_case.status || "N/A",
          test_case.description&.truncate(100) || "N/A"
        ]
      end
      
      pdf.table(test_case_data,
        header: true,
        width: pdf.bounds.width,
        cell_style: { size: 9, padding: 4 }
      )
    end

    send_data pdf.render, 
      filename: "manual_test_report_#{@test_suite.id}_#{Date.current}.pdf",
      type: 'application/pdf',
      disposition: 'attachment'
  end
end