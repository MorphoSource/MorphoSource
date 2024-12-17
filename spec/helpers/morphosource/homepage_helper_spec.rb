require 'rails_helper'

RSpec.describe Morphosource::HomepageHelper, type: :helper do

  describe 'featured_projects' do

    let(:guest)                   { FactoryBot.build(:user, :guest) }
    let(:ability)                 { ::Ability.new(guest) }
    let(:scope)                   { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }

    let(:project_collection_type) { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS) }
    let(:team_collection_type)    { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Teams::SETTINGS) }

    let!(:collection_A)           { FactoryBot.create(:organization_collection_document, collection_type_gid_ssim: [OrganizationCollection.collection_type.gid]) }
    let!(:collection_B)           { FactoryBot.create(:team_document, collection_type_gid_ssim: [team_collection_type.gid]) }
    let!(:collection_C)           { FactoryBot.create(:project_document, collection_type_gid_ssim: [project_collection_type.gid]) }
    let!(:collection_D)           { FactoryBot.create(:media_list_document, collection_type_gid_ssim: [MediaList.collection_type.gid] ) }
    let!(:collection_E)           { FactoryBot.create(:sequential_section_list_document, collection_type_gid_ssim: [SequentialSectionList.collection_type.gid] ) }
    let!(:collection_F)           { FactoryBot.create(:project_document, collection_type_gid_ssim: [OrganizationCollection.collection_type.gid] ) }
    let!(:media)                  { FactoryBot.create(:media_document) }
    let!(:specimen)               { FactoryBot.create(:biological_specimen_document) }
    let!(:device)                 { FactoryBot.create(:device_document) }
    let!(:imaging_event)          { FactoryBot.create(:imaging_event_document) }

    let(:team_project_ids)        { [collection_B.id, collection_C.id, collection_F.id] }
    let(:selected_ids)            { [collection_A.id, collection_C.id, collection_D.id, collection_E.id] }
    let(:rando_object_ids)        { [media.id, specimen.id, device.id, imaging_event.id] }
    let(:valid_ids)               { selected_ids }
    let(:non_valid_ids)           { ['A', media.id, device.id] }

    before do
      allow_any_instance_of(Blacklight::SearchBuilder).to receive(:scope).and_return(scope)
    end

    it 'returns appropriate projects' do
      # no featured projects configured
      Rails.application.config.featured_project_ids = []
      expect(ids(helper.featured_projects)).to match_array(team_project_ids)
      # findable featured projects configured
      Rails.application.config.featured_project_ids = selected_ids
      expect(ids(helper.featured_projects)).to match_array(selected_ids)
      # un-findable featured projects configured
      Rails.application.config.featured_project_ids = ['A','B','C']
      expect(ids(helper.featured_projects)).to match_array(team_project_ids)
      # featured project ids includes non-collection objects
      Rails.application.config.featured_project_ids = rando_object_ids
      expect(ids(helper.featured_projects)).to match_array(team_project_ids)
      # featured project ids includes a mix of valid and non-valid ids
      Rails.application.config.featured_project_ids = valid_ids + non_valid_ids
      expect(ids(helper.featured_projects)).to match_array(valid_ids)
    end
  end

  def ids(docs)
    docs.map(&:id)
  end

end
