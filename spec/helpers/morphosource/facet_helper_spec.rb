require 'rails_helper'

RSpec.describe Morphosource::FacetHelper, type: :helper do

  describe 'record_title_by_id' do
    let(:bl_config)   { CatalogController.blacklight_config }

    before do
      def controller
        nil
      end
      allow(controller).to receive(:blacklight_config).and_return(bl_config)
    end

    context 'record with id exists' do
      let!(:project) { Collection.create(title: ['project'], collection_type_gid: project_collection_type.to_global_id) }

      it 'returns the record title' do
        expect(collection_title_by_id(project.id)).to eq(project.title.first)
      end
    end
    context 'record with id does not exist' do
      let(:id)  { 'X' }
      it 'returns record id not found' do
        expect(collection_title_by_id(id)).to eq("Record #{id} Not Found")
      end
    end
  end

  describe 'visibility_label' do
    context 'open' do
      let(:team)  { Collection.create(title: ['team'], collection_type_gid: team_collection_type.to_global_id, visibility: 'open') }
      it { expect(helper.visibility_label(team.visibility)).to eq('Public') }
    end
    context 'restricted' do
      let(:team)  { Collection.create(title: ['team'], collection_type_gid: team_collection_type.to_global_id) }
      it { expect(helper.visibility_label(team.visibility)).to eq('Private') }
    end
  end

  describe 'device_title_by_id' do
    let(:device) { FactoryBot.create(:device_resource, title: ['device model'], creator: ['device make']) }

    before do
      ActiveFedora::SolrService.add(
        {
          id: device.id.to_s,
          'creator_ssim' => device.creator,
          'title_tesim' => device.title
        },
        softCommit: true
      )
      ActiveFedora::SolrService.commit
    end

    it 'returns the device title' do
      expect(device_title_by_id(device.id)).to eq("#{device.creator.first} #{device.title.first}")
    end
  end

  describe 'user_name_by_id' do
    context 'user with ms_id exists' do
      let(:user) { FactoryBot.create(:user, ms_id: 'abc123') }
      it 'returns the user name' do
        expect(user_name_by_id(user.ms_id)).to eq(user.name)
      end
    end

    context 'OrganizationCollection with id exists' do
      let(:org) { FactoryBot.create(:organization_collection_document) }
      it 'returns the collection title' do
        expect(user_name_by_id(org.id)).to eq(org.title.first)
      end
    end

    context 'no user or collection with id exists' do
      context 'another solr document with id exists' do
        let(:media) { FactoryBot.create(:media_document) }
        it 'returns unknown user with id' do
          expect(user_name_by_id(media.id)).to eq("Unknown User #{media.id.upcase}")
        end
      end
      context 'no solr document with id exists' do
        let(:id) { 'nonexistent' }
        it 'returns unknown user with id' do
          expect(user_name_by_id(id)).to eq("Unknown User #{id.upcase}")
        end
      end
    end
  end

end
