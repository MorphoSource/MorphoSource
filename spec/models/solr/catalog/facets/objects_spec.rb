require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  let(:specimen)              { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
  let(:cho)                   { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes']) }
  let(:organization)          { Organization.create(title: ['organization']) }
  let(:specimen_doc)          { SolrDocument.find(specimen.id) }
  let(:cho_doc)               { SolrDocument.find(cho.id) }
  let(:updated_specimen_doc)  { SolrDocument.find(specimen.id) }
  let(:updated_cho_doc)       { SolrDocument.find(cho.id) }

  describe 'organization facet' do
    let(:organization2) { Organization.create(title: ['organization 2']) }
    before do
      organization.members << specimen
      organization2.members << cho
      [organization, organization2].each(&:save)
    end
    context 'object is associated with a different organization' do
      it 'updates the object solr doc' do
        expect(specimen_doc['organization_tesim']).to eq(organization.title.to_a)
        expect(cho_doc['organization_tesim']).to eq(organization2.title.to_a)

        organization.members -= [specimen]
        organization.members << cho
        organization2.members -= [cho]
        organization2.members << specimen
        [organization, organization2].each(&:save)

        expect(updated_specimen_doc['organization_tesim']).to eq(organization2.title.to_a)
        expect(updated_cho_doc['organization_tesim']).to eq(organization.title.to_a)
      end
    end
    context 'organization title is changed' do
      let(:new_org_title)   { ['new organization title'] }
      let(:new_org_2_title) { ['new organization 2 title'] }

      it 'updates the object solr doc' do
        expect(specimen_doc['organization_tesim']).to eq(organization.title.to_a)
        expect(cho_doc['organization_tesim']).to eq(organization2.title.to_a)

        organization.title = new_org_title
        organization2.title = new_org_2_title
        [organization, organization2].each(&:save)

        expect(updated_specimen_doc['organization_tesim']).to eq(new_org_title)
        expect(updated_cho_doc['organization_tesim']).to eq(new_org_2_title)
      end
    end
  end

  describe 'media type, media keyword, media collection' do
    let(:media1)                { Media.create(title: ['media1'], visibility: 'open', keyword: ['A','B','C'], media_type: ["CTImageSeries"]) }
    let(:media2)                { Media.create(title: ['media2'], visibility: 'open', keyword: ['1','2','3'], media_type: ["PhotogrammetryImageSeries"]) }
    let(:media3)                { Media.create(title: ['media3'], visibility: 'open', keyword: ['apple','banana','cherry'], media_type: ["Image"]) }
    let(:imaging_event)         { ImagingEvent.create(title: ['imaging event']) }
    let(:processing_event1)     { ProcessingEvent.create(title: ['processing event 1']) }
    let(:processing_event2)     { ProcessingEvent.create(title: ['processing event 2']) }
    let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team') }
    let(:team)                  { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, visibility: 'open') }
    let(:team2)                 { Collection.create(title: ['Team2'], collection_type_gid: team_collection_type.gid, visibility: 'open') }

    let(:works)                 { [specimen, cho, media1, media2, media3, imaging_event, processing_event1, processing_event2] }

    before do
      specimen.members << imaging_event
      cho.members << imaging_event
      [specimen, cho].each(&:save)

      media1.member_of_collections << team
      media2.member_of_collections << team2
      [media1, media2].each(&:save)
    end

    context 'child media is added to the object' do
      context 'media is added to the imaging event' do
        it 'updates the object solr records' do
          # specimen
          expect(specimen_doc['public_media_keyword_tesim']).to be_nil
          expect(specimen_doc['public_media_type_tesim']).to be_nil
          expect(specimen_doc['media_member_of_public_collection_ids_ssim']).to be_nil
          # cho
          expect(cho_doc['public_media_keyword_tesim']).to be_nil
          expect(cho_doc['public_media_type_tesim']).to be_nil
          expect(cho_doc['media_member_of_public_collection_ids_ssim']).to be_nil

          imaging_event.members << media1
          imaging_event.save

          # specimen
          expect(updated_specimen_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a)
          expect(updated_specimen_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a)
          expect(updated_specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a)
          # cho
          expect(updated_cho_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a)
          expect(updated_cho_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a)
          expect(updated_cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a)
        end
      end
      context 'media is added to a processing event' do
        before do
          imaging_event.members << media1
          imaging_event.save
        end
        it 'updates the object solr records' do
          # specimen
          expect(specimen_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a)
          expect(specimen_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a)
          expect(specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a)
          # cho
          expect(cho_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a)
          expect(cho_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a)
          expect(cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a)

          media1.members << processing_event1
          processing_event1.members << media2
          [media1, processing_event1].each(&:save)

          # specimen
          expect(updated_specimen_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a + media2.keyword.to_a)
          expect(updated_specimen_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a + media2.human_readable_media_type.to_a)
          expect(updated_specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a + media2.member_of_collection_ids.to_a)
          # cho
          expect(updated_cho_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a + media2.keyword.to_a)
          expect(updated_cho_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a + media2.human_readable_media_type.to_a)
          expect(updated_cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a + media2.member_of_collection_ids.to_a)
        end
      end
    end
    context 'child media is removed from the object' do
      before do
        imaging_event.members << media1
        media1.members << processing_event1
        processing_event1.members << media2
        [imaging_event, media1, processing_event1].each(&:save)
      end
      context 'media is removed from an imaging event' do
        it 'udpates the object solr record' do
          # specimen
          expect(specimen_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a + media2.keyword.to_a)
          expect(specimen_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a + media2.human_readable_media_type.to_a)
          expect(specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a + media2.member_of_collection_ids.to_a)

          # cho
          expect(cho_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a + media2.keyword.to_a)
          expect(cho_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a + media2.human_readable_media_type.to_a)
          expect(cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a + media2.member_of_collection_ids.to_a)

          imaging_event.members -= [media1]
          imaging_event.save
          # specimen
          expect(updated_specimen_doc['public_media_keyword_tesim']).to be_nil
          expect(updated_specimen_doc['public_media_type_tesim']).to  be_nil
          expect(updated_specimen_doc['media_member_of_public_collection_ids_ssim']).to be_nil
          # # cho
          expect(updated_cho_doc['public_media_keyword_tesim']).to be_nil
          expect(updated_cho_doc['public_media_type_tesim']).to be_nil
          expect(updated_cho_doc['media_member_of_public_collection_ids_ssim']).to be_nil
        end
      end
      context 'media is removed from a processing event' do
        it 'updates the object solr doc' do
          # specimen
          expect(specimen_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a + media2.keyword.to_a)
          expect(specimen_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a + media2.human_readable_media_type.to_a)
          expect(specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a + media2.member_of_collection_ids.to_a)
          # cho
          expect(cho_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a + media2.keyword.to_a)
          expect(cho_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a + media2.human_readable_media_type.to_a)
          expect(cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a + media2.member_of_collection_ids.to_a)

          processing_event1.members -= [media2]
          processing_event1.save

          # specimen
          expect(updated_specimen_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a)
          expect(updated_specimen_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a)
          expect(updated_specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a)
          # cho
          expect(updated_cho_doc['public_media_keyword_tesim'].to_a).to match_array(media1.keyword.to_a)
          expect(updated_cho_doc['public_media_type_tesim'].to_a).to match_array(media1.human_readable_media_type.to_a)
          expect(updated_cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array(media1.member_of_collection_ids.to_a)
        end
      end
    end
    context 'media metadata changes' do
      before do
        imaging_event.members << media1
        media1.members << processing_event1
        processing_event1.members << media2
        media2.members << processing_event2
        processing_event2.members << media3
        [imaging_event, media1, processing_event1, media2, processing_event2, media3].each(&:save)
      end

      let(:old_keywords)    { ['A','B','C','1','2','3','apple','banana','cherry'] }
      let(:old_media_types) { ["CT Image Series","Photogrammetry Image Series", "Image"] }
      let(:new_keywords)    { ['D','E','F','4','5','6','tomato','cucumber','celery'] }
      let(:new_media_types) { ["Video", "Mesh", "Foo"] }

      it 'updates the object solr records' do
        # specimen
        expect(specimen_doc['public_media_keyword_tesim'].to_a).to match_array(old_keywords)
        expect(specimen_doc['public_media_type_tesim'].to_a).to match_array(old_media_types)

        # cho
        expect(cho_doc['public_media_keyword_tesim'].to_a).to match_array(old_keywords)
        expect(cho_doc['public_media_type_tesim'].to_a).to match_array(old_media_types)

        media1.keyword = ['D','E','F']
        media1.media_type = ["Video"]
        media2.keyword = ['4','5','6']
        media2.media_type = ["Mesh"]
        media3.keyword = ['tomato','cucumber','celery']
        media3.media_type = ["Foo"]
        [media1,media2,media3].each(&:save)

        # specimen
        expect(updated_specimen_doc['public_media_keyword_tesim'].to_a).to match_array(new_keywords)
        expect(updated_specimen_doc['public_media_type_tesim'].to_a).to match_array(new_media_types)

        # cho
        expect(updated_cho_doc['public_media_keyword_tesim'].to_a).to match_array(new_keywords)
        expect(updated_cho_doc['public_media_type_tesim'].to_a).to match_array(new_media_types)
      end

      describe 'media collections facet' do
        let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
        let(:project)                 { Collection.create(title: ['Project1'], collection_type_gid: project_collection_type.gid, visibility: 'open') }

        context 'media is added to a collection' do
          before do
            imaging_event.members << media1
            media1.members << processing_event1
            processing_event1.members << media2
            media2.members << processing_event2
            processing_event2.members << media3
            [imaging_event, media1, processing_event1, media2, processing_event2, media3].each(&:save)
          end

          it 'updates the object solr doc' do
            # specimen
            expect(specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id, team2.id])
            # cho
            expect(cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id, team2.id])

            media3.member_of_collections += [project]
            media3.save

            # specimen
            expect(updated_specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id, team2.id, project.id])
            # cho
            expect(updated_cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id, team2.id, project.id])
          end
        end
        context 'media is removed from a collection' do
          before do
            imaging_event.members << media1
            media1.members << processing_event1
            processing_event1.members << media2
            [imaging_event, media1, processing_event1, media2].each(&:save)
          end
          it 'updates the object solr doc' do
            expect(specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id, team2.id])
            # cho
            expect(cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id, team2.id])

            media2.member_of_collections -= [team2]
            media2.save

            # specimen
            expect(updated_specimen_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id])
            # cho
            expect(updated_cho_doc['media_member_of_public_collection_ids_ssim'].to_a).to match_array([team.id])
          end
        end
      end
    end
  end
end
