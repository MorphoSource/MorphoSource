# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DeviceResource`
require 'rails_helper'
require 'hyrax/specs/shared_specs/indexers'

RSpec.describe DeviceResourceIndexer do
  let(:indexer_class) { described_class }
  let(:resource) { DeviceResource.new }

  it_behaves_like 'a Hyrax::Resource indexer'

  describe '#to_solr' do
    subject(:solr_document) { described_class.new(resource: resource).generate_solr_document }

    before do
      resource.creator = ['creator']
      resource.ark = ['ark:/12345/m4/678910']
    end

    it 'indexes creator and ark fields' do
      expect(solr_document['creator_ssim']).to match_array(resource.creator)
      expect(solr_document['ark_tesim']).to match_array(resource.ark)
      expect(solr_document['ark_ssim']).to match_array(resource.ark)
    end

    context 'when an organization is present' do
      let(:organization) do
        instance_double('Organization',
                        id: 'org-123',
                        title: ['Organization'],
                        institution_name: ['Institution'])
      end

      before do
        allow(resource).to receive(:organization).and_return(organization)
      end

      it 'indexes organization fields' do
        expect(solr_document['device_organization_id_tesim']).to eq(organization.id)
        expect(solr_document['device_organization_id_ssim']).to eq(organization.id)
        expect(solr_document['device_organization_title_tesim']).to match_array(organization.title)
        expect(solr_document['device_organization_title_ssi']).to match_array(organization.title)
        expect(solr_document['device_organization_institution_name_tesim']).to match_array(organization.institution_name)
        expect(solr_document['device_organization_institution_name_ssim']).to match_array(organization.institution_name)
      end
    end
  end
end
