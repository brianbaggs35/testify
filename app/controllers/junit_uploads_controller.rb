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
    # Simple XML parsing for demo purposes
    # In a real application, you'd use a proper XML parser like Nokogiri
    content = file.read

    # Create some sample test results for demo
    # This would normally parse the actual XML structure
    sample_results = [
      { test_name: "sampleTest1", class_name: "com.example.Test", status: "passed", execution_time: 0.123 },
      { test_name: "sampleTest2", class_name: "com.example.Test", status: "failed", execution_time: 0.456, failure_message: "Assertion failed" },
      { test_name: "sampleTest3", class_name: "com.example.Test", status: "passed", execution_time: 0.789 }
    ]

    sample_results.each do |result|
      junit_upload.junit_test_results.create!(
        test_name: result[:test_name],
        class_name: result[:class_name],
        status: result[:status],
        execution_time: result[:execution_time],
        failure_message: result[:failure_message]
      )
    end
  end
end
