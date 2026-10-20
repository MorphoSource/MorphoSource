require 'rails_helper'

RSpec.describe Morphosource::IDigBioSearchController, type: :controller do

  describe '#search_idigbio_by_occurrence_id_ajax' do
    let(:params) { { oid: 'MCZ:Mamm:44858', organization_id: 'org1' } }
    let(:resolver) { instance_double(Morphosource::SpecimenSources::Resolver) }
    let(:record) do
      Morphosource::SpecimenSources::Record.new(
        source: Morphosource::SpecimenSources::IDigBioSource.new, id: 'uuid1', dataset_id: 'rs1',
        occurrence_id: 'MCZ:Mamm:44858',
        specimen_params: { 'occurrence_id' => 'MCZ:Mamm:44858', 'idigbio_uuid' => 'uuid1' },
        provider_taxonomy_params: {}, raw: {}
      )
    end

    before do
      allow(Morphosource::SpecimenSources::Resolver).to receive(:new)
        .with(organization_id: 'org1').and_return(resolver)
    end

    context 'when a record is found' do
      before do
        allow(record).to receive(:gbif_taxonomy_params).and_return({})
        allow(resolver).to receive(:find_by_occurrence_id).with('MCZ:Mamm:44858')
          .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: :found, record: record, candidates: [record]))
      end

      it 'returns the mapped specimen fields and source details' do
        post :search_idigbio_by_occurrence_id_ajax, params: params, format: :json
        expect(JSON.parse(response.body)).to include(
          'status' => 'found',
          'occurrence_id' => 'MCZ:Mamm:44858',
          'idigbio_uuid' => 'uuid1',
          'source' => 'idigbio',
          'source_label' => 'iDigBio',
          'record_id' => 'uuid1',
          'record_url' => 'https://www.idigbio.org/portal/records/uuid1',
          'candidate_count' => 1
        )
      end
    end

    context 'when the record belongs to another organization' do
      before do
        allow(resolver).to receive(:find_by_occurrence_id)
          .and_return(Morphosource::SpecimenSources::Resolver::Result.new(status: :org_mismatch, candidates: [record]))
      end

      it 'returns the org_mismatch status without specimen fields' do
        post :search_idigbio_by_occurrence_id_ajax, params: params, format: :json
        body = JSON.parse(response.body)
        expect(body['status']).to eq('org_mismatch')
        expect(body).not_to have_key('occurrence_id')
      end
    end
  end

end
