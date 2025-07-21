require 'rails_helper'

RSpec.describe JunitUpload, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      junit_upload = build(:junit_upload)
      expect(junit_upload).to be_valid
    end

    it 'requires a filename' do
      junit_upload = build(:junit_upload, filename: nil)
      expect(junit_upload).not_to be_valid
      expect(junit_upload.errors[:filename]).to include("can't be blank")
    end

    it 'requires a file_size' do
      junit_upload = build(:junit_upload, file_size: nil)
      expect(junit_upload).not_to be_valid
      expect(junit_upload.errors[:file_size]).to include("can't be blank")
    end

    it 'requires file_size to be greater than 0' do
      junit_upload = build(:junit_upload, file_size: 0)
      expect(junit_upload).not_to be_valid
      expect(junit_upload.errors[:file_size]).to include('must be greater than 0')
    end

    it 'requires a valid status' do
      valid_statuses = %w[Pending Parsed Error]
      valid_statuses.each do |status|
        junit_upload = build(:junit_upload, status: status)
        expect(junit_upload).to be_valid
      end

      junit_upload = build(:junit_upload, status: 'Invalid')
      expect(junit_upload).not_to be_valid
      expect(junit_upload.errors[:status]).to include('is not included in the list')
    end
  end

  describe 'associations' do
    it 'has many junit_test_results' do
      association = described_class.reflect_on_association(:junit_test_results)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has one attached file' do
      junit_upload = create(:junit_upload)
      expect(junit_upload).to respond_to(:file)
    end
  end

  describe 'scopes' do
    before do
      create(:junit_upload, status: 'Parsed')
      create(:junit_upload, status: 'Error')
      create(:junit_upload, status: 'Pending')
    end

    describe '.by_status' do
      it 'returns uploads with the specified status' do
        parsed_uploads = JunitUpload.by_status('Parsed')
        expect(parsed_uploads.count).to eq(1)
        expect(parsed_uploads.first.status).to eq('Parsed')
      end
    end

    describe '.recent' do
      it 'orders uploads by uploaded_at desc' do
        uploads = JunitUpload.recent
        expect(uploads.to_sql).to include('ORDER BY uploaded_at DESC')
      end
    end
  end

  describe 'instance methods' do
    let(:junit_upload) { create(:junit_upload, :with_test_results) }

    before do
      # Create specific test results for counting
      create(:junit_test_result, junit_upload: junit_upload, status: 'passed')
      create(:junit_test_result, junit_upload: junit_upload, status: 'passed')
      create(:junit_test_result, junit_upload: junit_upload, status: 'failed')
      create(:junit_test_result, junit_upload: junit_upload, status: 'error')
      create(:junit_test_result, junit_upload: junit_upload, status: 'skipped')
    end

    describe '#passed_count' do
      it 'returns the count of passed tests' do
        expect(junit_upload.passed_count).to eq(2)
      end
    end

    describe '#failed_count' do
      it 'returns the count of failed tests' do
        expect(junit_upload.failed_count).to eq(1)
      end
    end

    describe '#error_count' do
      it 'returns the count of error tests' do
        expect(junit_upload.error_count).to eq(1)
      end
    end

    describe '#skipped_count' do
      it 'returns the count of skipped tests' do
        expect(junit_upload.skipped_count).to eq(1)
      end
    end

    describe '#total_count' do
      it 'returns the total count of test results' do
        expect(junit_upload.total_count).to be > 5 # includes factory-created ones
      end
    end

    describe '#file_size_human' do
      it 'returns file size in bytes for small files' do
        junit_upload.file_size = 500
        expect(junit_upload.file_size_human).to eq('500 B')
      end

      it 'returns file size in KB for medium files' do
        junit_upload.file_size = 1024
        expect(junit_upload.file_size_human).to eq('1.0 KB')
      end

      it 'returns file size in MB for large files' do
        junit_upload.file_size = 1024 * 1024
        expect(junit_upload.file_size_human).to eq('1.0 MB')
      end
    end
  end

  describe 'factory' do
    it 'creates a valid junit upload' do
      junit_upload = create(:junit_upload)
      expect(junit_upload).to be_persisted
      expect(junit_upload).to be_valid
    end

    it 'creates junit upload with test results when using trait' do
      junit_upload = create(:junit_upload, :with_test_results)
      expect(junit_upload.junit_test_results.count).to eq(5)
    end
  end
end
