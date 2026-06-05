require 'rails_helper'
require 'support/ms_derivative_service'

RSpec.describe Morphosource::MsFileSetDerivativesService do
  let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type).and_return(FileSet.mesh_mime_types.first)
    end
  end

  subject { described_class.new(file_set) }

  it_behaves_like "a Morphosource::DerivativeService"

  describe '#create_derivatives FileSetSizeInfo update' do
    let(:image_mime) { FileSet.image_mime_types.first }
    let(:file_set) do
      klass = class_double('FileSet',
        audio_mime_types:   [],
        video_mime_types:   [],
        image_mime_types:   [image_mime],
        mesh_mime_types:    [],
        archive_mime_types: []
      )
      instance_double('FileSet', id: 'fs-deriv-001', class: klass, mime_type: image_mime)
    end

    let(:deriv_path) { '/derivatives/fs-deriv-001/thumbnail.jpg' }
    let(:service)    { described_class.new(file_set) }

    before do
      allow(Morphosource::DerivativePath)
        .to receive(:derivatives_for_reference).with('fs-deriv-001')
        .and_return([deriv_path])
      allow(File).to receive(:size?).with(deriv_path).and_return(55_000)
      allow(service).to receive(:create_image_derivatives)
    end

    it 'calls upsert_for_file_set with derivative sizes after create_derivatives' do
      expect(FileSetSizeInfo).to receive(:upsert_for_file_set).with(
        file_set,
        derivatives:                  { 'thumbnail.jpg' => 55_000 },
        summed_derivatives_file_size: 55_000
      )
      service.create_derivatives('filename.jpg')
    end

    it 'updates FileSetSizeInfo even when derivative generation raises (ensure block)' do
      allow(service).to receive(:create_image_derivatives).and_raise(StandardError, 'convert error')
      expect(FileSetSizeInfo).to receive(:upsert_for_file_set)
      expect { service.create_derivatives('filename.jpg') }.to raise_error(StandardError)
    end
  end
end