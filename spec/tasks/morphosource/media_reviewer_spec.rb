require 'rails_helper'
require 'rake'

describe 'Media reviewer migration support', type: :task do
  before { Rails.application.load_tasks if Rake::Task.tasks.empty? }

  describe Morphosource::MediaReviewerVerification do
    it 'refuses to compare legacy state after the read-path cutover' do
      expect { described_class.new.call }.to raise_error(/before.*cutover/)
    end
  end

  describe 'morphosource:download_reviewer:reindex_media' do
    let(:task) { Rake::Task['morphosource:download_reviewer:reindex_media'] }
    let!(:media) { FactoryBot.create(:media) }
    let!(:other_media) { FactoryBot.create(:media) }

    before do
      task.reenable
      # Creating the second work resets the factory's earlier Media.find stub.
      allow(Media).to receive(:find).with(media.id).and_return(media)
      allow(Media).to receive(:find).with(other_media.id).and_return(other_media)
    end

    it 'reindexes every Media synchronously without saving or publishing events' do
      expect(media).to receive(:update_index).once.and_call_original
      expect(other_media).to receive(:update_index).once.and_call_original
      expect(media).not_to receive(:save)
      expect(other_media).not_to receive(:save)
      expect(Hyrax.publisher).not_to receive(:publish)

      task.invoke
    end

    it 'continues after a record failure, fails the task and allows a complete rerun' do
      allow(Morphosource::MediaReviewerBatches).to receive(:each).and_yield([media.id, other_media.id])
      allow(media).to receive(:update_index).and_raise(StandardError, 'Solr unavailable')
      expect(other_media).to receive(:update_index).twice.and_call_original

      expect { task.invoke }.to raise_error(SystemExit)

      allow(media).to receive(:update_index).and_call_original
      task.reenable
      expect { task.invoke }.not_to raise_error
    end

    [ActiveFedora::ObjectNotFoundError, Ldp::Gone].each do |error_class|
      it "reports and skips deleted Media when loading raises #{error_class}" do
        allow(Morphosource::MediaReviewerBatches).to receive(:each).and_yield([media.id, other_media.id])
        allow(Media).to receive(:find).with(media.id).and_raise(error_class)
        expect(media).not_to receive(:update_index)
        expect(other_media).to receive(:update_index).and_call_original
        message = "#{media.id}: in Solr but deleted from Fedora; skipped"
        expect(Rails.logger).to receive(:warn).with("[morphosource:download_reviewer:reindex_media] #{message}")

        expect { task.invoke }.to output(a_string_including(
          message, 'Media reindex complete: processed 2; failed 0; orphaned 1'
        )).to_stdout
      end

      it "counts an existing Media as failed when indexing raises #{error_class}" do
        allow(Morphosource::MediaReviewerBatches).to receive(:each).and_yield([media.id, other_media.id])
        allow(media).to receive(:update_index).and_raise(error_class)
        expect(other_media).to receive(:update_index).and_call_original

        expect do
          expect { task.invoke }.to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
        end.to output(a_string_including('Media reindex complete: processed 2; failed 1; orphaned 0')).to_stdout
      end
    end
  end
end
