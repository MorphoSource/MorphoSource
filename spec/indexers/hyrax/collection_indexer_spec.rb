require 'rails_helper'

RSpec.describe Hyrax::CollectionIndexer do

  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team') }
  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid) }
  let!(:organization)  { Organization.create(title: ['Organization Title'], team_id: [team.id])}

  subject(:solr_document) { Hyrax::CollectionIndexer.new(team).generate_solr_document }

  describe 'custom fields' do
    it 'indexes linked_organization' do
      expect(subject['linked_organization_sim']).to eq(organization.title)
    end
  end
end
