require 'rails_helper'
require 'vcr_helper'

RSpec.describe Morphosource::SpecimenSources::IDigBioSource, :vcr do
  subject(:source) { described_class.new }

  describe '#find_by_id' do
    let(:uuid) { '061594f4-69a3-41ff-9396-dac55cc8409b' }

    it 'returns a record with params suitable for BiologicalSpecimen construction' do
      record = source.find_by_id(uuid)
      expect(record.id).to eq(uuid)
      expect(record.source_label).to eq('iDigBio')
      expect(record.url).to eq("https://www.idigbio.org/portal/records/#{uuid}")
      expect(record.specimen_params['idigbio_uuid']).to eq(uuid)
      expect(record.specimen_params).to have_key('idigbio_recordset_id')
      expect(record.specimen_params['vouchered']).to eq('Yes')
      expect(record.taxonomy_param_sets).to include(:provider, :gbif)
    end

    it 'returns nil for a blank UUID' do
      expect(source.find_by_id('')).to be_nil
    end
  end

  describe '#find_by_occurrence_id' do
    it 'returns exact occurrence ID matches' do
      records = source.find_by_occurrence_id('urn:catalog:CM:VP:604')
      expect(records).not_to be_empty
      expect(records.first.occurrence_id.downcase).to eq('urn:catalog:cm:vp:604')
      expect(records.first.taxonomy_param_sets).to include(:provider, :gbif)
    end

    it 'returns no records for an unknown occurrence ID' do
      expect(source.find_by_occurrence_id('urn:catalog:CM:VP:604-not-found')).to eq([])
    end

    it 'raises SourceError when the API errors' do
      allow(Morphosource::IDigBio).to receive(:search).and_return(status: :error, message: 'timed out')
      expect { source.find_by_occurrence_id('urn:catalog:CM:VP:604') }
        .to raise_error(Morphosource::SpecimenSources::SourceError, 'timed out')
    end
  end

  describe 'sex filtering' do
    let(:idb) do
      { 'uuid' => 'u1', 'indexTerms' => { 'recordset' => 'rs1' },
        'data' => { 'dwc:occurrenceID' => 'urn:catalog:X:Y:12345', 'dwc:sex' => sex } }
    end

    before do
      allow(Morphosource::IDigBio).to receive(:view).and_return(status: :success, data: idb)
    end

    context 'with a controlled sex value' do
      let(:sex) { 'male' }

      it 'keeps it' do
        expect(source.find_by_id('u1').specimen_params['sex']).to eq('male')
      end
    end

    context 'with an uncontrolled sex value' do
      let(:sex) { 'not a sex' }

      it 'drops it' do
        expect(source.find_by_id('u1').specimen_params).not_to have_key('sex')
      end
    end
  end
end
