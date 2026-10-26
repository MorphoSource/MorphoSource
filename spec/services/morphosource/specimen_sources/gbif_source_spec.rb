require 'rails_helper'
require 'vcr_helper'

RSpec.describe Morphosource::SpecimenSources::GbifSource, :vcr do
  subject(:source) { described_class.new }

  let(:occurrence_id) { 'https://arctos.database.museum/guid/MVZ:Bird:178506' }

  describe '#find_by_occurrence_id' do
    it 'returns records mapped from the verbatim values' do
      record = source.find_by_occurrence_id(occurrence_id).first
      expect(record.source_label).to eq('GBIF')
      expect(record.dataset_id).to eq('e3b959d6-fcbe-4a28-a166-e4a807c340a0')
      expect(record.url).to eq("https://www.gbif.org/occurrence/#{record.id}")
      expect(record.specimen_params).to include(
        'gbif_occurrence_key' => record.id,
        'gbif_dataset_key' => 'e3b959d6-fcbe-4a28-a166-e4a807c340a0',
        'remote_source' => 'gbif',
        'vouchered' => 'Yes',
        'institution_code' => 'MVZ',
        'catalog_number' => 'MVZ:Bird:178506',
        'occurrence_id' => occurrence_id
      )
      expect(record.specimen_params['original_location']).to be_present
      expect(record.specimen_params['creator']).to be_an(Array)
      expect(record.provider_taxonomy_params['taxonomy_genus']).to eq('Cyanocitta')
    end

    it 'returns no records for an unknown occurrence ID' do
      expect(source.find_by_occurrence_id('urn:catalog:NOPE:NOPE:99999999')).to eq([])
    end

    it 'raises SourceError when the API errors' do
      allow(Morphosource::Gbif).to receive(:occurrence_search).and_return(status: :error, message: 'timed out')
      expect { source.find_by_occurrence_id(occurrence_id) }
        .to raise_error(Morphosource::SpecimenSources::SourceError, 'timed out')
    end
  end

  describe '#find_by_id' do
    it 'returns the record for a GBIF occurrence key' do
      expect(source.find_by_id('5146756742').occurrence_id).to eq(occurrence_id)
    end

    it 'returns nil for a blank key' do
      expect(source.find_by_id('')).to be_nil
    end
  end

  describe 'interpreted fallback' do
    let(:occurrence) do
      { 'key' => 1, 'datasetKey' => 'ds1', 'occurrenceID' => 'urn:catalog:X:Y:12345',
        'catalogNumber' => 'interpreted-cat', 'institutionCode' => 'INT', 'sex' => 'MALE' }
    end

    before do
      allow(Morphosource::Gbif).to receive(:occurrence).and_return(status: :success, data: occurrence)
    end

    it 'uses verbatim values over interpreted ones' do
      allow(Morphosource::Gbif).to receive(:occurrence_verbatim).and_return(
        status: :success, data: { 'http://rs.tdwg.org/dwc/terms/catalogNumber' => 'verbatim-cat' }
      )
      params = source.find_by_id('1').specimen_params
      expect(params['catalog_number']).to eq('verbatim-cat')
      expect(params['institution_code']).to eq('INT')
    end

    it 'falls back to interpreted values when the verbatim lookup fails' do
      allow(Morphosource::Gbif).to receive(:occurrence_verbatim).and_return(status: :error, message: 'boom')
      params = source.find_by_id('1').specimen_params
      expect(params['catalog_number']).to eq('interpreted-cat')
      expect(params['sex']).to eq('MALE')
    end
  end

  describe 'original_location precedence' do
    # Pins the order of the three DATA_BSO_MAPPING terms that feed original_location
    def original_location_for(verbatim: {}, interpreted: {})
      occurrence = { 'key' => 1, 'datasetKey' => 'ds1', 'occurrenceID' => 'urn:catalog:X:Y:12345' }.merge(interpreted)
      allow(Morphosource::Gbif).to receive(:occurrence).and_return(status: :success, data: occurrence)
      allow(Morphosource::Gbif).to receive(:occurrence_verbatim).and_return(
        status: :success, data: verbatim.transform_keys { |term| "http://rs.tdwg.org/dwc/terms/#{term}" }
      )
      source.find_by_id('1').specimen_params['original_location']
    end

    it 'prefers locality over verbatimLocality and country' do
      expect(original_location_for(verbatim: { 'locality' => 'Ridge trail', 'verbatimLocality' => '1 mi N of Ridge trail',
                                               'country' => 'United States' })).to eq('Ridge trail')
    end

    it 'uses verbatimLocality when locality is missing' do
      expect(original_location_for(verbatim: { 'verbatimLocality' => '1 mi N of Ridge trail', 'country' => 'United States' }))
        .to eq('1 mi N of Ridge trail')
    end

    it 'keeps a verbatim verbatimLocality ahead of an interpreted country' do
      expect(original_location_for(verbatim: { 'verbatimLocality' => '1 mi N of Ridge trail' },
                                   interpreted: { 'country' => 'United States of America' })).to eq('1 mi N of Ridge trail')
    end

    it 'falls back to country only when no locality is given' do
      expect(original_location_for(verbatim: { 'country' => 'United States' })).to eq('United States')
    end

    it 'never uses the interpreted countryCode' do
      expect(original_location_for(interpreted: { 'countryCode' => 'US', 'country' => 'United States of America' }))
        .to eq('United States of America')
    end
  end

  describe '#gbif_taxonomy_params' do
    let(:record) do
      Morphosource::SpecimenSources::Record.new(
        source: source, id: '1', dataset_id: 'ds1', occurrence_id: 'oid', specimen_params: {},
        provider_taxonomy_params: {}, raw: { 'taxonKey' => 111, 'acceptedTaxonKey' => 222 }
      )
    end

    it 'looks up the accepted taxon' do
      expect(Morphosource::GbifSearchService).to receive(:taxonomy_params_from_gbif).with(222).and_return('gbif_key' => '222')
      expect(record.gbif_taxonomy_params).to eq('gbif_key' => '222')
    end
  end
end
