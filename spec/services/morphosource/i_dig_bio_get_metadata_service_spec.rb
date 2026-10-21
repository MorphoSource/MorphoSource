require 'rails_helper'

RSpec.describe Morphosource::IDigBioGetMetadataService do
  let(:specimen) do
    {
      'id' => 'bso1',
      'occurrence_id_tesim' => ['urn:catalog:TEST:VP:1234'],
      'organization_id_tesim' => ['org1']
    }
  end
  let(:resolver) { instance_double(Morphosource::SpecimenSources::Resolver) }
  let(:source) { Morphosource::SpecimenSources::IDigBioSource.new }
  let(:record) do
    Morphosource::SpecimenSources::Record.new(
      source: source, id: 'uuid1', dataset_id: 'rs1', occurrence_id: 'urn:catalog:TEST:VP:1234',
      specimen_params: { 'idigbio_uuid' => 'uuid1', 'catalog_number' => '1234' },
      provider_taxonomy_params: { 'taxonomy_genus' => 'Cyanocitta' }, raw: {}
    )
  end
  let(:linker) do
    instance_double(Morphosource::SpecimenSources::TaxonomyLinker,
                    canonical_taxonomy_id: 'tax1', taxonomy_id_array: ['tax1'], taxonomy_params_array: [])
  end

  subject { described_class.call(specimen) }

  before do
    allow(Morphosource::SpecimenSources::Resolver).to receive(:new)
      .with(organization_id: ['org1']).and_return(resolver)
  end

  describe '.call' do
    context 'when a remote record is found' do
      before do
        allow(resolver).to receive(:find_by_occurrence_id).with(['urn:catalog:TEST:VP:1234'])
          .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: :found, record: record, candidates: [record]))
        allow(record).to receive(:taxonomy_param_sets).and_return(provider: {}, gbif: {})
        allow(Morphosource::SpecimenSources::TaxonomyLinker).to receive(:call).and_return(linker)
      end

      it 'returns taxonomy and specimen params for the update' do
        expect(subject).to eq(
          canonical_taxonomy_id: 'tax1',
          taxonomy_id_array: ['tax1'],
          taxonomy_params_array: [],
          biospec_model_params: { 'idigbio_uuid' => 'uuid1', 'catalog_number' => '1234' }
        )
      end
    end

    [:not_found, :org_mismatch, :invalid_occurrence_id].each do |status|
      context "when the resolver returns #{status}" do
        before do
          allow(resolver).to receive(:find_by_occurrence_id)
            .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: status, candidates: []))
        end

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end
  end

  describe '.idigbio_record_different_from_specimen?' do
    let(:solr_specimen) { { 'id' => 'bso1', 'catalog_number_tesim' => ['1234'], 'occurrence_id_tesim' => ['OID'] } }

    it 'is false when mapped fields match (case-insensitive)' do
      params = { biospec_model_params: { 'catalog_number' => '1234', 'occurrence_id' => 'oid' } }
      expect(described_class.idigbio_record_different_from_specimen?(solr_specimen, params)).to eq(false)
    end

    it 'is true when a mapped field differs' do
      params = { biospec_model_params: { 'catalog_number' => '9999' } }
      expect(described_class.idigbio_record_different_from_specimen?(solr_specimen, params)).to eq(true)
    end

    it 'compares sex, latitude and longitude against their Solr fields' do
      solr = solr_specimen.merge('sex_tesim' => ['Female'], 'latitude_tesim' => ['42.0673'], 'longitude_tesim' => ['-124.1661'])
      params = { biospec_model_params: { 'sex' => 'female', 'latitude' => '42.0673', 'longitude' => '-124.1661' } }
      expect(described_class.idigbio_record_different_from_specimen?(solr, params)).to eq(false)
    end

    it 'is true when the record comes from a different source' do
      solr = solr_specimen.merge('remote_source_tesim' => ['idigbio'])
      params = { biospec_model_params: { 'remote_source' => 'gbif' } }
      expect(described_class.idigbio_record_different_from_specimen?(solr, params)).to eq(true)
    end

    it 'is true when there are new taxonomies to create' do
      params = { taxonomy_params_array: [{ 'taxonomy_genus' => 'X' }], biospec_model_params: {} }
      expect(described_class.idigbio_record_different_from_specimen?(solr_specimen, params)).to eq(true)
    end
  end
end
