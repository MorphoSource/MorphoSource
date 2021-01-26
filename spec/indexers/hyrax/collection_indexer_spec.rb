require 'rails_helper'

RSpec.describe Hyrax::CollectionIndexer do

  let!(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team') }
  let!(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid) }
  let!(:organization)  { Organization.create(title: ['Organization Title'], team_id: [team.id]) }

  subject(:solr_document) { SolrDocument.find(team.id) }

  describe 'custom fields' do
    it 'indexes linked_organization' do
      expect(subject['linked_organization_ssim']).to eq([organization.title.first])
      expect(subject['linked_organization_tesim']).to eq([organization.title.first])
    end
    it 'indexes linked_organization_id' do
      expect(subject['linked_organization_id_ssi']).to eq(organization.id)
    end
  end
end
