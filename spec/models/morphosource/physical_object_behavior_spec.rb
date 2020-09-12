require 'rails_helper'

RSpec.describe Morphosource::PhysicalObjectBehavior do

  let(:specimen)  { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes']) }
  let(:cho) { CulturalHeritageObject.create(title: ['CHO'], vouchered: ['Yes']) }

  describe 'parent organizations' do
    let(:organization)  { Organization.create(title: ['Organization'])}
    let(:works) { [organization, specimen, cho] }

    before do
      organization.ordered_members << specimen
      organization.ordered_members << cho
      works.each(&:save)
      works.each(&:reload)
    end

    describe '#organizations' do
      it 'returns the parent organizations' do
        expect(specimen.organizations).to eq([organization])
        expect(cho.organizations).to eq([organization])
      end
    end
    describe '#organization_titles' do
      it 'returns the parent organization titles' do
        expect(specimen.organization_titles[0]).to eq(organization.title[0])
        expect(cho.organization_titles[0]).to eq(organization.title[0])
      end
    end
  end

  describe 'child media' do
    let(:media1)  { Media.create(title: ['Media 1'], media_type: ['CTImageSeries'], keyword: ['red', 'yellow', 'blue']) }
    let(:media2)  { Media.create(title: ['Media 2'], media_type: ['PhotogrammetryImageSeries'], keyword: ['green', 'orange', 'purple']) }
    let(:imaging_event)  { ImagingEvent.create(title: ['Imaging Event'])}

    let(:works) { [specimen, cho, imaging_event, media1, media2]}

    before do
      specimen.ordered_members << imaging_event
      cho.ordered_members << imaging_event
      imaging_event.ordered_members << media1 << media2
      works.each(&:save)
      works.each(&:reload)
    end

    it 'accesses child media metadata' do
      # specimen
      expect(specimen.media).to match_array([media1, media2])
      expect(specimen.media_types).to match_array([media1.media_type[0], media2.media_type[0]])
      expect(specimen.human_readable_media_types).to match_array([media1.human_readable_media_type.first, media2.human_readable_media_type.first])
      expect(specimen.media_keyword).to match_array(media1.keyword + media2.keyword)
      # cho
      expect(cho.media).to match_array([media1, media2])
      expect(cho.media_types).to match_array([media1.media_type[0], media2.media_type[0]])
      expect(cho.human_readable_media_types).to match_array([media1.human_readable_media_type.first, media2.human_readable_media_type.first])
      expect(cho.media_keyword).to match_array(media1.keyword + media2.keyword)
    end

    describe '#media_collections' do
      let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
      let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
      let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid) }
      let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid) }

      before do
        media1.member_of_collections << team
        media2.member_of_collections << project
        [media1, media2].each(&:save)
        [media1, media2].each(&:reload)
      end

      it 'returns the media collection titles' do
        # specimen
        expect(specimen.media_collections).to match_array(media1.member_of_collections.map{ |c| c.title.first } + media2.member_of_collections.map{ |c| c.title.first })
        # cho
        expect(cho.media_collections).to match_array(media1.member_of_collections.map{ |c| c.title.first } + media2.member_of_collections.map{ |c| c.title.first })
      end
    end
  end
end
