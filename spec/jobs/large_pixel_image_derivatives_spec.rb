require 'rails_helper'

RSpec.describe CharacterizeJob do
  describe 'perform' do
    let(:file_set) { FactoryBot.create(:file_set) }

    let(:thumbnail_path) { Hyrax::DerivativePath.derivative_path_for_reference(file_set.id, 'thumbnail') }

    after do
      FileUtils.rm(thumbnail_path) if File.exist?(thumbnail_path)
    end

    shared_examples 'a large image that characterizes and derives successfully' do
      # CharacterizeJob#perform enqueues CreateDerivativesJob via perform_later, which
      # runs inline in the test env (config.active_job.queue_adapter = :inline). Force
      # the :test adapter here so CreateDerivativesJob is only enqueued, not executed,
      # letting characterization be verified independently of derivative creation.
      it 'characterizes the full-size image' do
        original_adapter = ActiveJob::Base.queue_adapter
        ActiveJob::Base.queue_adapter = :test
        begin
          Hydra::Works::AddFileToFileSet.call(file_set, image_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        ensure
          ActiveJob::Base.queue_adapter = original_adapter
        end

        solr_doc = SolrDocument.find(file_set.id)
        expect(solr_doc[:mime_type_ssi]).to eq('image/jpeg')
        expect(file_set.characterization_proxy.width.first.to_i).to eq(expected_width)
        expect(file_set.characterization_proxy.height.first.to_i).to eq(expected_height)
      end

      it 'creates a thumbnail derivative' do
        Hydra::Works::AddFileToFileSet.call(file_set, image_file, :original_file)
        described_class.perform_now(file_set, file_set.original_file.id, file_path_string)

        expect(File.exist?(thumbnail_path)).to be(true)
      end
    end

    context 'image exceeding the ImageMagick width/height policy limit' do
      let(:file_path_string) { fixture_path + '/images/large_pixel_width_20000x1000.jpg' }
      let(:image_file) { File.open(file_path_string) }
      let(:expected_width) { 20_000 }
      let(:expected_height) { 1_000 }

      include_examples 'a large image that characterizes and derives successfully'
    end

    context 'image exceeding the ImageMagick area/pixel-cache policy limit' do
      let(:file_path_string) { fixture_path + '/images/large_pixel_area_15000x13500.jpg' }
      let(:image_file) { File.open(file_path_string) }
      let(:expected_width) { 15_000 }
      let(:expected_height) { 13_500 }

      include_examples 'a large image that characterizes and derives successfully'
    end
  end
end
