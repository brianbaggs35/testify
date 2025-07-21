class JunitUploadsController < ApplicationController
  before_action :set_junit_upload, only: [ :show, :destroy ]

  def index
    @junit_uploads = JunitUpload.includes(:junit_test_results).recent
  end

  def show
    @junit_test_results = @junit_upload.junit_test_results
  end

  def new
    @junit_upload = JunitUpload.new
  end

  def create
    @junit_upload = JunitUpload.new(junit_upload_params)

    if params[:junit_upload][:file].present?
      file = params[:junit_upload][:file]

      # Validate file type
      unless file.content_type == "text/xml" || file.content_type == "application/xml" || file.original_filename.end_with?(".xml")
        @junit_upload.errors.add(:file, "must be an XML file")
        render :new, status: :unprocessable_entity
        return
      end

      # Validate file size (10MB limit)
      if file.size > 10.megabytes
        @junit_upload.errors.add(:file, "must be less than 10MB")
        render :new, status: :unprocessable_entity
        return
      end

      @junit_upload.filename = file.original_filename
      @junit_upload.file_size = file.size
      @junit_upload.uploaded_at = Time.current
      @junit_upload.status = "Pending"

      if @junit_upload.save
        @junit_upload.file.attach(file)

        # Parse the XML file (simplified for demo)
        begin
          parse_junit_xml(@junit_upload, file)
          @junit_upload.update!(status: "Parsed")
          redirect_to @junit_upload, notice: "JUnit file was successfully uploaded and parsed."
        rescue => e
          @junit_upload.update!(status: "Error")
          redirect_to @junit_upload, alert: "File uploaded but parsing failed: #{e.message}"
        end
      else
        render :new, status: :unprocessable_entity
      end
    else
      @junit_upload.errors.add(:file, "must be present")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @junit_upload.destroy
    redirect_to junit_uploads_url, notice: "JUnit upload was successfully deleted."
  end

  private

  def set_junit_upload
    @junit_upload = JunitUpload.find(params[:id])
  end

  def junit_upload_params
    params.require(:junit_upload).permit(:file)
  end

  def parse_junit_xml(junit_upload, file)
    require 'nokogiri'
    
    content = file.read
    doc = Nokogiri::XML(content)
    
    # Handle multiple possible JUnit XML formats
    test_cases = doc.xpath('//testcase')
    
    if test_cases.empty?
      # Try alternative xpath patterns
      test_cases = doc.xpath('//test-case') || doc.xpath('//case')
    end
    
    test_cases.each do |test_case|
      test_name = test_case['name'] || test_case['testname'] || test_case.text.strip.split.first
      class_name = test_case['classname'] || test_case['class'] || 'Unknown'
      execution_time = (test_case['time'] || test_case['duration'] || '0').to_f
      
      # Determine status and failure message
      status = 'passed'
      failure_message = nil
      
      if test_case.xpath('.//failure').any?
        status = 'failed'
        failure_node = test_case.xpath('.//failure').first
        failure_message = failure_node['message'] || failure_node.text || 'Test failed'
      elsif test_case.xpath('.//error').any?
        status = 'error'
        error_node = test_case.xpath('.//error').first  
        failure_message = error_node['message'] || error_node.text || 'Test error'
      elsif test_case.xpath('.//skipped').any?
        status = 'skipped'
        skipped_node = test_case.xpath('.//skipped').first
        failure_message = skipped_node['message'] || skipped_node.text || 'Test skipped'
      end
      
      # Skip creating duplicate entries
      next if junit_upload.junit_test_results.exists?(
        test_name: test_name,
        class_name: class_name
      )
      
      junit_upload.junit_test_results.create!(
        test_name: test_name,
        class_name: class_name,
        status: status,
        execution_time: execution_time,
        failure_message: failure_message
      )
    end
    
    # If no test cases were found, try parsing testsuite summary
    if test_cases.empty?
      testsuites = doc.xpath('//testsuite')
      testsuites.each do |testsuite|
        tests_count = (testsuite['tests'] || '0').to_i
        failures_count = (testsuite['failures'] || '0').to_i
        errors_count = (testsuite['errors'] || '0').to_i
        skipped_count = (testsuite['skipped'] || '0').to_i
        
        # Create summary entries if individual test cases aren't available
        if tests_count > 0 && test_cases.empty?
          suite_name = testsuite['name'] || 'Test Suite'
          
          # Create representative test results based on summary
          passed_count = tests_count - failures_count - errors_count - skipped_count
          
          passed_count.times do |i|
            junit_upload.junit_test_results.create!(
              test_name: "#{suite_name}_test_#{i + 1}",
              class_name: suite_name,
              status: 'passed',
              execution_time: 0.1
            )
          end
          
          failures_count.times do |i|
            junit_upload.junit_test_results.create!(
              test_name: "#{suite_name}_failed_test_#{i + 1}",
              class_name: suite_name,
              status: 'failed',
              execution_time: 0.1,
              failure_message: 'Test failed (from summary)'
            )
          end
          
          errors_count.times do |i|
            junit_upload.junit_test_results.create!(
              test_name: "#{suite_name}_error_test_#{i + 1}",
              class_name: suite_name,
              status: 'error',
              execution_time: 0.1,
              failure_message: 'Test error (from summary)'
            )
          end
          
          skipped_count.times do |i|
            junit_upload.junit_test_results.create!(
              test_name: "#{suite_name}_skipped_test_#{i + 1}",
              class_name: suite_name,
              status: 'skipped',
              execution_time: 0.0,
              failure_message: 'Test skipped (from summary)'
            )
          end
        end
      end
    end
  end
end
