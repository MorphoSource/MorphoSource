require 'rails_helper'

RSpec.describe Morphosource::CwAttachmentService do

  describe 'ProcessingEvent attachment' do
    let(:pe) { ProcessingEvent.create }
    let(:file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
    let(:field_name) { "description_attachment" }
    let(:expected_url) { "/uploads/processing_event/description_attachment/text.txt" }

    describe '.create' do
      it 'creates an attachment' do
        Morphosource::CwAttachmentService.create(pe, field_name, file, Morphosource.attachment_formats, true)
        expect(pe.description_attachment).to eq(expected_url)
      end

      it 'raises an error for unsupported file formats' do
        invalid_file = Rack::Test::UploadedFile.new('spec/fixtures/ms.zip', 'application/zip')
        expect {
          Morphosource::CwAttachmentService.create(pe, field_name, invalid_file, Morphosource.attachment_formats, true)
        }.to raise_error(ArgumentError, /Invalid file format/)
      end
    end

    describe '.delete' do
      it 'deletes an attachment' do
        Morphosource::CwAttachmentService.create(pe, field_name, file)
        expect {
          Morphosource::CwAttachmentService.delete(pe, field_name)
        }.to change { pe.description_attachment }.to(nil)
      end
    end
  end

end
