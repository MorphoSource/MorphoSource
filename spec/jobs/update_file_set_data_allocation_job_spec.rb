require 'rails_helper'

RSpec.describe UpdateFileSetDataAllocationJob do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform' do
    context 'when the FileSet parent is not a Media' do
      it 'exits silently when parent is nil' do
        file_set = double('FileSet', parent: nil)
        expect { described_class.perform_now(file_set) }.not_to raise_error
        expect(UpdateDataAllocationStorageJob).not_to have_been_enqueued
      end

      it 'exits silently when parent is a non-Media work' do
        non_media = double('BiologicalSpecimen')
        file_set = double('FileSet', parent: non_media)
        expect { described_class.perform_now(file_set) }.not_to raise_error
        expect(UpdateDataAllocationStorageJob).not_to have_been_enqueued
      end
    end

    context 'when the Media parent has no active fund code association' do
      # Media.create is sufficient here — no FCMA created, so the query returns nil
      let(:media) { Media.create(title: ['Test Media']) }
      let(:file_set) { double('FileSet', parent: media) }

      it 'exits silently without enqueuing UpdateDataAllocationStorageJob' do
        expect { described_class.perform_now(file_set) }.not_to raise_error
        expect(UpdateDataAllocationStorageJob).not_to have_been_enqueued
      end
    end
  end
end
