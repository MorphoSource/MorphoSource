# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Import::Slides::GetNewSlidesService do

  describe 'DATASET_KEY' do
    it { expect(described_class::DATASET_KEY).to eq('4bfac3ea-8763-4f4b-a71a-76a6f5f243d3') }
    it 'is the GBIF dataset key for MCZ' do
      response = RestClient.get "https://api.gbif.org/v1/dataset/#{described_class::DATASET_KEY}"
      expect(JSON.parse(response.body)['title']).to eq('Museum of Comparative Zoology, Harvard University')
    rescue StandardError => e
      # Allow to fail quietly if something is off with the GBIF API
      # GBIF API problems are covered by gbif_spec.
      puts "There was an error in accessing the GBIF api: #{e.message}"
    end
  end

  describe '.call' do
    it 'instantiates the search service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call
    end
  end

  describe '#call' do
    context 'gbif_search_results are empty' do
      before do
        allow(subject).to receive(:gbif_search_results).and_return({})
      end
      it 'returns an empty array' do
        expect(subject.call).to match_array([])
      end
    end

    context 'MCZ publishes new slide series' do
      let(:key1)            { '123' }
      let(:key2)            { '456' }
      let(:occurrence_id1)  { 'MCZ:SC:1234' }
      let(:occurrence_id2)  { 'MCZ:SC:5678' }
      let(:results) do
        [{ 'key' => key1, 'occurrenceID' => occurrence_id1 },
         { 'key' => key2, 'occurrenceID' => occurrence_id2 }]
      end
      before do
        allow(subject).to receive(:gbif_search_results).and_return(results)
      end

      context 'All series found in GBIF are new' do
        it 'calls ImportSlideSeriesJob twice and returns 2 keys' do
          expect(Morphosource::ImportSlideSeriesJob).to receive(:perform_later).twice
          expect(subject.call).to match_array([key1, key2])
        end
      end

      context 'One of the series is already in MorphoSource' do
        let(:admin)         { FactoryBot.create(:admin) }
        # specimen occurrence_id == occurrence_id1
        let(:specimen)      { FactoryBot.create(:biological_specimen, occurrence_id: [occurrence_id1]) }
        let(:device)        { FactoryBot.create(:device) }
        let(:media)         { FactoryBot.create(:media) }
        let(:imaging_event) { FactoryBot.create(:imaging_event, ie_modality: ['SequentialSectionScan'], device_id: [device.id], physical_object_id: [specimen.id]) }
        let(:list)          { FactoryBot.create(:sequential_section_list, depositor: admin.ms_id) }

        before do
          imaging_event.ordered_members << media
          imaging_event.save
          media.member_of_collections << list
          media.save!
        end

        it { expect(subject.list_occurrence_ids).to match_array([occurrence_id1]) }

        it 'calls ImportSlideSeriesJob for one occurrence_key' do
          expect(Morphosource::ImportSlideSeriesJob).to receive(:perform_later).once
          expect(subject.call).to match_array([key2])
        end
      end
    end
  end
end
