require 'rails_helper'

RSpec.describe Hyrax::Forms::CollectionForm do

  let(:depositor)       { FactoryBot.create(:contributor) }
  let(:ability)         { Ability.new(depositor) }
  let(:repository)      { double }
  let(:form)            { described_class.new(collection, ability, repository) }
  let(:media_id_1)      { "1" }
  let(:media_id_2)      { "2" }
  let(:media_id_3)      { "3" }
  let(:response)        { Blacklight::Solr::Response.new({
                                                            responseHeader: {
                                                              status: 0,
                                                              params: {}
                                                            },
                                                            response: {
                                                              docs: [
                                                                { "id"=>media_id_1 },
                                                                { "id"=>media_id_2 },
                                                                { "id"=>media_id_3 }
                                                              ]
                                                            }
                                                          }, {}) }

  describe 'all_files_with_access' do
    before do
      allow_any_instance_of(search_builder_class).to receive(:query).and_return({})
      allow_any_instance_of(MediaCatalogController).to receive_message_chain(:blacklight_config, :repository, :search).and_return(response)
    end
    context 'collection is an organization collection' do
      let(:collection)            { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
      let(:search_builder_class)  { Morphosource::Collections::OrganizationCollections::MediaSearchBuilder }

      it 'calls the OrganizationCollections::MediaSearchBuilder' do
        expect_any_instance_of(search_builder_class).to receive(:query)
        form.send(:all_files_with_access)
      end
      it 'returns an array of ids' do
        expect(form.send(:all_files_with_access)).to match_array([[media_id_1, media_id_1], [media_id_2, media_id_2], [media_id_3, media_id_3]])
      end
    end
    context 'collection is not an organization collection' do
      let(:collection)            { FactoryBot.create(:project) }
      let(:search_builder_class)  { Morphosource::Collections::MediaSearchBuilder }

      it 'calls the Collections::MediaSearchBuilder' do
        expect_any_instance_of(search_builder_class).to receive(:query)
        form.send(:all_files_with_access)
      end
      it 'returns an array of ids' do
        expect(form.send(:all_files_with_access)).to match_array([[media_id_1, media_id_1], [media_id_2, media_id_2], [media_id_3, media_id_3]])
      end
    end
  end
end