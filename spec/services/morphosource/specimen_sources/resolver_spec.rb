require 'rails_helper'

RSpec.describe Morphosource::SpecimenSources::Resolver do
  let(:occurrence_id) { 'urn:catalog:TEST:VP:1234' }

  # Minimal in-memory source for exercising the resolver's ordering and org rules
  let(:source_class) do
    Class.new(Morphosource::SpecimenSources::Base) do
      attr_reader :key, :label, :org_dataset_field

      def initialize(key:, records: [], error: nil)
        @key = key
        @label = key.to_s
        @org_dataset_field = "#{key}_dataset_tesim"
        @records = records
        @error = error
      end

      def build_record(id:, dataset_id:)
        Morphosource::SpecimenSources::Record.new(
          source: self, id: id, dataset_id: dataset_id, occurrence_id: 'oid',
          specimen_params: {}, provider_taxonomy_params: {}, raw: {}
        )
      end

      def with_records(records)
        @records = records
        self
      end

      def find_by_occurrence_id(_occurrence_id)
        raise @error if @error
        @records
      end

      def find_by_id(id)
        raise @error if @error
        @records.find { |r| r.id == id }
      end
    end
  end

  let(:first_source) { source_class.new(key: :first) }
  let(:second_source) { source_class.new(key: :second) }
  let(:organization) { nil }
  let(:organization_id) { organization ? 'org1' : nil }

  subject(:resolver) { described_class.new(organization_id: organization_id, sources: [first_source, second_source]) }

  before do
    allow(SolrDocument).to receive(:find).with('org1').and_return(organization) if organization
  end

  describe '.valid_occurrence_id?' do
    it 'requires 8+ characters with a letter and a digit' do
      expect(described_class.valid_occurrence_id?('1234567')).to eq(false)
      expect(described_class.valid_occurrence_id?('12345678')).to eq(false)
      expect(described_class.valid_occurrence_id?('abcdefgh')).to eq(false)
      expect(described_class.valid_occurrence_id?('abcdefg7')).to eq(true)
    end
  end

  describe '#find_by_occurrence_id' do
    it 'returns :invalid_occurrence_id without querying sources' do
      expect(first_source).not_to receive(:find_by_occurrence_id)
      expect(resolver.find_by_occurrence_id('1').status).to eq(:invalid_occurrence_id)
    end

    it 'accepts an array occurrence ID and strips whitespace' do
      first_source.with_records([first_source.build_record(id: 'a', dataset_id: nil)])
      expect(resolver.find_by_occurrence_id(["  #{occurrence_id}  "])).to be_found
    end

    it 'returns :not_found when no source has a record' do
      result = resolver.find_by_occurrence_id(occurrence_id)
      expect(result.status).to eq(:not_found)
      expect(result.record).to be_nil
      expect(result.source_errors).to eq([])
    end

    it 'uses the first source in priority order that has a record' do
      first_source.with_records([first_source.build_record(id: 'a', dataset_id: nil)])
      second_source.with_records([second_source.build_record(id: 'b', dataset_id: nil)])
      expect(resolver.find_by_occurrence_id(occurrence_id).record.id).to eq('a')
    end

    it 'falls through to the next source when a source errors' do
      failing = source_class.new(key: :first, error: Morphosource::SpecimenSources::SourceError.new('timeout'))
      second_source.with_records([second_source.build_record(id: 'b', dataset_id: nil)])
      result = described_class.new(sources: [failing, second_source]).find_by_occurrence_id(occurrence_id)
      expect(result.record.id).to eq('b')
      expect(result.source_errors).to eq([:first])
    end

    it 'uses the first record when a source returns several' do
      first_source.with_records([first_source.build_record(id: 'a', dataset_id: nil),
                                 first_source.build_record(id: 'a2', dataset_id: nil)])
      result = resolver.find_by_occurrence_id(occurrence_id)
      expect(result.record.id).to eq('a')
      expect(result.candidates.length).to eq(2)
    end

    context 'when the organization has dataset IDs for a source' do
      let(:organization) { SolrDocument.new('id' => 'org1', 'first_dataset_tesim' => ['ds1']) }

      it 'prefers the record whose dataset matches the organization' do
        first_source.with_records([first_source.build_record(id: 'other', dataset_id: 'ds2'),
                                   first_source.build_record(id: 'mine', dataset_id: 'ds1')])
        expect(resolver.find_by_occurrence_id(occurrence_id).record.id).to eq('mine')
      end

      it 'tries the next source when no record matches the organization' do
        first_source.with_records([first_source.build_record(id: 'other', dataset_id: 'ds2')])
        second_source.with_records([second_source.build_record(id: 'b', dataset_id: 'anything')])
        expect(resolver.find_by_occurrence_id(occurrence_id).record.id).to eq('b')
      end

      it 'returns :org_mismatch when every hit is from another dataset' do
        first_source.with_records([first_source.build_record(id: 'other', dataset_id: 'ds2')])
        result = resolver.find_by_occurrence_id(occurrence_id)
        expect(result.status).to eq(:org_mismatch)
        expect(result.candidates.map(&:id)).to eq(['other'])
      end

      it 'accepts a record with no dataset ID' do
        first_source.with_records([first_source.build_record(id: 'a', dataset_id: nil)])
        expect(resolver.find_by_occurrence_id(occurrence_id)).to be_found
      end
    end

    context 'when the organization has no dataset IDs for a source' do
      let(:organization) { SolrDocument.new('id' => 'org1') }

      it 'skips the organization check' do
        first_source.with_records([first_source.build_record(id: 'a', dataset_id: 'any')])
        expect(resolver.find_by_occurrence_id(occurrence_id)).to be_found
      end
    end
  end

  describe '#find_by_id' do
    it 'returns nil when the source errors' do
      allow(Morphosource::SpecimenSources).to receive(:for).with(:first)
        .and_return(source_class.new(key: :first, error: StandardError.new('boom')))
      expect(resolver.find_by_id(:first, 'a')).to be_nil
    end
  end
end
