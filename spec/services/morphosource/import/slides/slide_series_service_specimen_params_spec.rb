require 'rails_helper'

# Separate from slide_series_service_spec.rb, which stubs specimen_params_from_occurrence_id for every example
RSpec.describe Morphosource::Import::Slides::SlideSeriesService do
  describe '#specimen_params_from_occurrence_id' do
    let(:occurrence_id) { 'MCZ:SC:3793' }
    let(:resolver) { instance_double(Morphosource::SpecimenSources::Resolver) }
    let(:service) do
      # skip initialize, which fetches the GBIF occurrence and finds or creates a collection
      described_class.allocate.tap do |s|
        s.instance_variable_set(:@occurrence_json, { 'occurrenceID' => occurrence_id })
        s.instance_variable_set(:@organization, double('organization', id: 'org1'))
      end
    end

    before do
      allow(Morphosource::SpecimenSources::Resolver).to receive(:new).with(organization_id: 'org1').and_return(resolver)
    end

    it 'returns symbolized, array-wrapped params from the remote record' do
      record = instance_double(Morphosource::SpecimenSources::Record,
                               specimen_params: { 'catalog_number' => 'MCZ:SC:3793', 'creator' => ['A. Collector'] })
      allow(resolver).to receive(:find_by_occurrence_id).with(occurrence_id)
        .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: :found, record: record, candidates: [record]))

      expect(service.send(:specimen_params_from_occurrence_id))
        .to eq(catalog_number: ['MCZ:SC:3793'], creator: ['A. Collector'])
    end

    it 'returns no params when no record is found' do
      allow(resolver).to receive(:find_by_occurrence_id)
        .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: :not_found, candidates: []))

      expect(service.send(:specimen_params_from_occurrence_id)).to eq({})
    end
  end
end
