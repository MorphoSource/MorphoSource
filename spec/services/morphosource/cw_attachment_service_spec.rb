require 'rails_helper'

RSpec.describe Morphosource::CwAttachmentService do
  let(:model) { ProcessingEvent.create }
  let(:file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
  let(:field_name) { "processing_event_attachment" }

  describe '.create' do
    it 'creates an attachment' do
byebug
      url = Morphosource::CwAttachmentService.create(model, field_name, file)
      expect(model.reload.processing_event_attachment).to eq(url)
    end

    it 'raises an error for unsupported file formats' do
      invalid_file = Rack::Test::UploadedFile.new('spec/fixtures/ms.zip', 'application/zip')
      expect {
        Morphosource::CwAttachmentService.create(model, field_name, invalid_file, ['.txt'])
      }.to raise_error(ArgumentError, /Invalid file format/)
    end
  end

  describe '.delete' do
    it 'deletes an attachment' do
      Morphosource::CwAttachmentService.create(model, field_name, file)
      expect {
        Morphosource::CwAttachmentService.delete(model, field_name)
      }.to change { model.reload.processing_event_attachment }.to(nil)
    end
  end
end
