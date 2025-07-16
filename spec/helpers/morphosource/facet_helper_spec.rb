require 'rails_helper'

RSpec.describe Morphosource::FacetHelper, type: :helper do

  describe 'collection_title_by_id' do
    let(:repository)  { Blacklight::Solr::Repository.new(bl_config) }
    let(:bl_config)   { MediaCatalogController.blacklight_config }

    before do
      def controller.repository
        nil
      end
      allow(controller).to receive(:repository).and_return(repository)
    end

    context 'collection with id exists' do
      let!(:project)                 { Collection.create(title: ['project'], collection_type_gid: project_collection_type.to_global_id) }

      it 'returns the collection title' do
        expect(collection_title_by_id(project.id)).to eq(project.title.first)
      end
    end
    context 'collection with id does not exist' do
      let(:id)  { 'X' }
      it 'returns collection id not found' do
        expect(collection_title_by_id(id)).to eq("Collection #{id} Not Found")
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
    let(:device)  { FactoryBot.create(:device, title: ['device model'], creator: ['device make']) }
    it 'returns the device title' do
      expect(device_title_by_id(device.id)).to eq("#{device.creator.first} #{device.title.first}")
    end
  end

end
