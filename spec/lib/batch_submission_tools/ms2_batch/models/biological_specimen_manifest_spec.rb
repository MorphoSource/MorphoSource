require 'rails_helper'

RSpec.describe BatchSubmissionTools::Ms2Batch::Models::BiologicalSpecimenManifest do
  let(:occurrence_id) { 'urn:catalog:TEST:VP:1234' }
  let(:initial_attrs) do
    { occurrence_id: [occurrence_id], institution_code: ['SHEET'], collection_code: ['C1'], catalog_number: ['1'] }
  end
  let(:resolver) { instance_double(Morphosource::SpecimenSources::Resolver) }
  let(:record) do
    Morphosource::SpecimenSources::Record.new(
      source: Morphosource::SpecimenSources::IDigBioSource.new, id: 'uuid1', dataset_id: 'rs1', occurrence_id: occurrence_id,
      specimen_params: { 'occurrence_id' => occurrence_id, 'institution_code' => 'REMOTE', 'idigbio_uuid' => 'uuid1' },
      provider_taxonomy_params: { 'taxonomy_genus' => 'Cyanocitta' }, raw: {}
    )
  end

  subject(:manifest) do
    described_class.new(initial_attrs: initial_attrs, depositor: 'dep1', organization_id: 'org1')
  end

  before do
    allow(Morphosource::SpecimenSources::Resolver).to receive(:new).with(organization_id: 'org1').and_return(resolver)
  end

  context 'when the occurrence ID resolves to a remote record' do
    before do
      allow(record).to receive(:gbif_taxonomy_params).and_return({})
      allow(resolver).to receive(:find_by_occurrence_id).with([occurrence_id])
        .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: :found, record: record, candidates: [record]))
    end

    it 'imports the specimen attributes and taxonomy from the record' do
      expect(manifest.work_imported).to eq(true)
      expect(manifest.attrs).to include('institution_code' => 'REMOTE', 'idigbio_uuid' => 'uuid1', organization_id: ['org1'])
      expect(manifest.imported_taxonomy_param_sets).to eq(provider: { 'taxonomy_genus' => 'Cyanocitta' }, gbif: {})
    end
  end

  [:org_mismatch, :not_found].each do |status|
    context "when the resolver returns #{status}" do
      before do
        allow(resolver).to receive(:find_by_occurrence_id)
          .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: status, candidates: []))
      end

      it 'creates the specimen from the sheet values' do
        expect(manifest.work_imported).to eq(false)
        expect(manifest.attrs[:institution_code]).to eq(['SHEET'])
        expect(manifest.imported_taxonomy_param_sets).to be_nil
      end
    end
  end
end
