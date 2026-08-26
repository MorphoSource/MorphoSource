require 'rails_helper'

RSpec.describe UpdateFileSetDataAllocationJob do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform' do
    let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set) }

    context 'when the FileSet parent is not a Media' do
      it 'exits silently when parent is nil' do
        allow(file_set).to receive(:parent).and_return(nil)
        expect { described_class.perform_now(file_set) }.not_to raise_error
        expect(UpdateDataAllocationStorageJob).not_to have_been_enqueued
      end

      it 'exits silently when parent is a non-Media work' do
        non_media = double('BiologicalSpecimen')
        allow(file_set).to receive(:parent).and_return(non_media)
        expect { described_class.perform_now(file_set) }.not_to raise_error
        expect(UpdateDataAllocationStorageJob).not_to have_been_enqueued
      end
    end

    context 'when the Media parent has no active fund code association' do
      let(:media) { Media.create(title: ['Test Media']) }

      before { allow(file_set).to receive(:parent).and_return(media) }

      it 'exits silently without enqueuing UpdateDataAllocationStorageJob' do
        expect { described_class.perform_now(file_set) }.not_to raise_error
        expect(UpdateDataAllocationStorageJob).not_to have_been_enqueued
      end
    end

    context 'when the active fund code association has a nil fund_code (orphaned FCMA)' do
      let(:media) { Media.create(title: ['Test Media']) }
      let(:fcma) { double('FundCodeMediaAssociation', fund_code: nil) }

      before do
        allow(file_set).to receive(:parent).and_return(media)
        allow(FundCodeMediaAssociation).to receive(:where).and_return(double(first: fcma))
      end

      it 'exits silently without enqueuing UpdateDataAllocationStorageJob' do
        expect { described_class.perform_now(file_set) }.not_to raise_error
        expect(UpdateDataAllocationStorageJob).not_to have_been_enqueued
      end
    end

    context 'when the Media parent has an active fund code association with a data allocation' do
      let(:user) { User.create!(email: 'fc_owner@example.com', password: 'password') }
      let(:fund_code) { FundCode.create!(user: user, storage_total_gb: 100) }
      let(:data_allocation) { fund_code.data_allocation }
      let(:media) { Media.create(title: ['Test Media']) }

      before do
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media.id, active: true)
        allow(file_set).to receive(:parent).and_return(media)
      end

      it 'enqueues UpdateDataAllocationStorageJob with the data allocation' do
        expect { described_class.perform_now(file_set) }
          .to have_enqueued_job(UpdateDataAllocationStorageJob)
          .with(data_allocation)
      end
    end
  end
end
