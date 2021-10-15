require 'rails_helper'
RSpec.describe Morphosource::Facets::Collections do
  let(:admin)                   { User.create(email: 'admin@email.com', password: 'password')}
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:private_team)            { Collection.create(title: ['private team'], collection_type_gid: team_collection_type.gid, visibility: 'restricted', depositor: admin.ms_id) }
  let(:open_team)               { Collection.create(title: ['open team'], collection_type_gid: team_collection_type.gid, visibility: 'open', depositor: admin.ms_id) }

  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:private_project)         { Collection.create(title: ['private project'], collection_type_gid: project_collection_type.gid, visibility: 'restricted', depositor: admin.ms_id) }
  let(:open_project)            { Collection.create(title: ['open project'], collection_type_gid: project_collection_type.gid, visibility: 'open', depositor: admin.ms_id) }

  let(:open_media)              { Media.create(title: ['open media'], visibility: 'open')}
  let(:open_media2)             { Media.create(title: ['open media2'], visibility: 'open')}
  let(:private_media)           { Media.create(title: ['private media'], visibility: 'restricted')}
  let(:specimen)                { BiologicalSpecimen.create(title: ['specimen'], visibility: 'open', vouchered: ['Yes'])}
  let(:cho)                     { CulturalHeritageObject.create(title: ['cho'], visibility: 'open', vouchered: ['Yes'])}
  let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let(:imaging_event1)          { ImagingEvent.create(title: ['imaging event 1'], device_id: [device.id], physical_object_id: [specimen.id], ie_modality: device.modality) }
  let(:imaging_event2)          { ImagingEvent.create(title: ['imaging event 2'], device_id: [device.id], physical_object_id: [cho.id], ie_modality: device.modality) }

  let(:works)                   { [open_media, open_media2, private_media, specimen, cho, imaging_event1, imaging_event2] }
  let(:media)                   { [open_media, open_media2, private_media]}
  let(:collections)             { [private_team, open_team, private_project, open_project]}

  # both users have access to all media, user_with_access also has access to all collections
  let(:user_with_access)        { User.create(email: 'user1@email.com', password: 'password') }
  let(:user_without_access)     { User.create(email: 'user2@email.com', password: 'password') }

  before do
    collections.each do |c|
      c.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: c)
    end
    imaging_event1.ordered_members << open_media << open_media2
    imaging_event2.ordered_members << private_media
    [open_media, private_media].each do |m|
      m.member_of_collections += collections
      m.edit_users += [user_with_access, user_without_access]
    end
    open_media2.member_of_collections += [private_team, private_project]
    private_team.viewers << user_with_access
    private_project.editors << user_with_access
    [private_team, private_project].each(&:save!)
    [private_team, private_project].each(&:update_index)
    user_with_access.reload
    works.each(&:save)
    works.each(&:update_index)
  end

  describe MediaCatalogController, :type => :controller do
    context 'user has access to all the collections' do
      before do
        sign_in user_with_access
      end

      it 'includes all the collections in the collection facets' do
        get :index
        facets = subject.instance_variable_get(:@response)["facet_counts"]["facet_fields"]
        team_facet = facets['member_of_team_ids_ssim']
        project_facet = facets['member_of_project_ids_ssim']
        expect(team_facet).to include(private_team.id, open_team.id)
        expect(project_facet).to include(private_project.id, open_project.id)

        # when clicking on 'more' to get paginated results
        # ordering the facet by number of results
        get :facet, params: {:id => 'member_of_team_ids_ssim' }
        display_facet = subject.instance_variable_get(:@display_facet)
        item1 = display_facet.items[0]
        item2 = display_facet.items[1]
        expect(item1.value).to eq(private_team.id)
        expect(item2.value).to eq(open_team.id)

        # when clicking on 'more' to get paginated results
        # ordering the facet alphabetically by title
        get :facet, params: { :id => 'member_of_team_ids_ssim', "facet.sort" => "index" }
        display_facet = subject.instance_variable_get(:@display_facet)
        item1 = display_facet.items[0]
        item2 = display_facet.items[1]
        expect(item1.value).to eq(open_team.id)
        expect(item2.value).to eq(private_team.id)
      end
    end

    context 'user has access to only the open collections' do
      before do
        sign_in user_without_access
      end

      it 'includes open collections in the collection facets' do
        get :index
        facets = subject.instance_variable_get(:@response)["facet_counts"]["facet_fields"]
        team_facet = facets['member_of_team_ids_ssim']
        project_facet = facets['member_of_project_ids_ssim']
        expect(team_facet).to include(open_team.id)
        expect(team_facet).not_to include(private_team.id)
        expect(project_facet).to include(open_project.id)
        expect(project_facet).not_to include(private_project.id)
      end
    end
  end
end
