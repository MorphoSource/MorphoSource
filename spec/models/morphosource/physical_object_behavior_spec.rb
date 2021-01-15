require 'rails_helper'

RSpec.describe Morphosource::PhysicalObjectBehavior do

  let(:organization)  { Organization.create(title: ['Organization']) }
  let(:specimen)      { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes'], organization_id: [organization.id]) }
  let(:cho)           { CulturalHeritageObject.create(title: ['CHO'], vouchered: ['Yes'], organization_id: [organization.id]) }

  describe 'parent organizations' do
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
    let(:public_media)    { Media.create(title: ['Public Media'], media_type: ['CTImageSeries'], keyword: ['red', 'yellow', 'blue'], visibility: 'open') }
    let(:private_media)   { Media.create(title: ['Private Media'], media_type: ['PhotogrammetryImageSeries'], keyword: ['green', 'orange', 'purple'], visibility: 'restricted') }
    let(:device)          { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event)   { ImagingEvent.create(title: ['Imaging Event'], device_id: [device.id], ie_modality: device.modality) }
    let(:imaging_event2)   { ImagingEvent.create(title: ['Imaging Event'], device_id: [device.id], ie_modality: device.modality) }
    let(:media)           { [public_media, private_media] }
    let(:works)           { [specimen, cho, imaging_event, imaging_event2, public_media, private_media] }

    before do
      specimen.ordered_members << imaging_event
      cho.ordered_members << imaging_event2
      imaging_event.ordered_members << public_media << private_media
      imaging_event2.ordered_members << public_media << private_media
      works.each(&:save)
      works.each(&:reload)
    end

    describe 'media_solr' do
      let(:public_media_solr)   { SolrDocument.find(public_media.id) }
      let(:private_media_solr)  { SolrDocument.find(private_media.id) }

      it 'returns descendant media solr records' do
        expect(specimen.media_solr.map(&:id)).to match_array([public_media.id, private_media.id])
        expect(cho.media_solr.map(&:id)).to match_array([public_media.id, private_media.id])
      end
    end

    describe '#related_media_ids' do
      it 'returns related media ids' do
        expect(specimen.related_media_ids).to match_array([public_media.id] + [private_media.id])
      end
    end

    describe '#media' do
      it 'returns all child media' do
        expect(specimen.media).to match_array([public_media, private_media])
        expect(cho.media).to match_array([public_media, private_media])
      end
    end

    describe '#public_media' do
      it 'returns only child public media' do
        expect(specimen.public_media).to match_array([public_media])
        expect(cho.public_media).to match_array([public_media])
      end
    end

    describe '#media_types' do
      it 'returns all child media types' do
        expect(specimen.media_types).to match_array(public_media.media_type + private_media.media_type)
        expect(cho.media_types).to match_array(public_media.media_type + private_media.media_type)
      end
    end

    describe '#public_media_types' do
      it 'returns only public child media types' do
        expect(specimen.public_media_types).to match_array(public_media.media_type)
        expect(cho.public_media_types).to match_array(public_media.media_type)
      end
    end

    describe '#human_readable_media_types' do
      it 'returns child media human readable media types' do
        expect(specimen.human_readable_media_types).to match_array(public_media.human_readable_media_type + private_media.human_readable_media_type)
        expect(cho.human_readable_media_types).to match_array(public_media.human_readable_media_type + private_media.human_readable_media_type)
      end
    end

    describe '#public_human_readable_media_types' do
      it 'returns only public child media human readable media types' do
        expect(specimen.public_human_readable_media_types).to match_array(public_media.human_readable_media_type)
        expect(cho.public_human_readable_media_types).to match_array(public_media.human_readable_media_type)
      end
    end

    describe '#media_keyword' do
      it 'returns all child media keywords' do
        expect(specimen.media_keyword).to match_array(public_media.keyword + private_media.keyword)
        expect(cho.media_keyword).to match_array(public_media.keyword + private_media.keyword)
      end
    end

    describe '#public_media_keyword' do
      it 'returns only public child media keywords' do
        expect(specimen.public_media_keyword).to match_array(public_media.keyword)
        expect(cho.public_media_keyword).to match_array(public_media.keyword)
      end
    end

    describe 'media collections' do
      let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
      let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
      let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, visibility: 'open')}
      let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, visibility: 'restricted') }

      before do
        public_media.member_of_collections << team
        private_media.member_of_collections << project
        media.each(&:save)
        media.each(&:reload)
      end

      describe '#media_collections' do
        it 'returns the media collection titles' do
          expect(specimen.media_collections).to match_array(team.title + project.title)
          expect(cho.media_collections).to match_array(team.title + project.title)
        end
      end

      describe '#media_member_of_public_collection_ids' do
        before do
          public_media.member_of_collections << project
          private_media.member_of_collections << team
          media.each(&:save)
          media.each(&:reload)
        end
        it 'returns only public collection ids for public media' do
          expect(specimen.media_member_of_public_collection_ids).to match_array([team.id])
          expect(cho.media_member_of_public_collection_ids).to match_array([team.id])
        end
      end
    end

  end
end
