require 'rails_helper'

RSpec.describe Morphosource::Works::IndexRelatedWorks do

  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                    { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid) }
  let(:new_team)                { Collection.create(title: ['new team'], collection_type_gid: team_collection_type.gid) }

  let(:organization)            { Organization.create(title: ['organization'], team_id: [team.id]) }
  let(:new_organization)        { Organization.create(title: ['new organization'])}

  let(:taxonomy)                { Taxonomy.create(title: ['taxonomy']) }

  let(:specimen)                { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes'], organization_id: [organization.id], taxonomy_id: [taxonomy.id]) }
  let(:cho)                     { CulturalHeritageObject.create(title: ['cho'], vouchered: ['No'], organization_id: [organization.id]) }
  let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let(:device2)                 { Device.create(title: ['device 2'], modality: ['Photography']) }

  let(:imaging_event1)          { ImagingEvent.create(title: ['imaging event 1'], device_id: [device.id], ie_modality: device.modality) }
  let(:media1a)                 { Media.create(title: ['media 1a']) }

  let(:processing_event1)       { ProcessingEvent.create(title: ['processing event 1']) }
  let(:media1b)                 { Media.create(title: ['media 1b']) }
  #
  let(:imaging_event2)          { ImagingEvent.create(title: ['imaging event 2'], device_id: [device.id], ie_modality: device.modality) }
  let(:media2a)                 { Media.create(title: ['media 2a']) }
  let(:processing_event2)       { ProcessingEvent.create(title: ['processing event 2']) }
  let(:media2b)                 { Media.create(title: ['media 2b']) }

  let(:media)                   { [media1a, media1b, media2a, media2b] }

  let(:works)                   { [specimen, cho, imaging_event1, media1a, processing_event1, media1b, imaging_event2, media2a, processing_event2, media2b] }

  before do

    specimen.ordered_members << imaging_event1
    imaging_event1.ordered_members << media1a
    media1a.ordered_members << processing_event1
    processing_event1.ordered_members << media1b

    cho.ordered_members << imaging_event2
    imaging_event2.ordered_members << media2a
    media2a.ordered_members << processing_event2
    processing_event2.ordered_members << media2b

    works.each(&:save)
    media.each(&:update_index)
  end

  describe 'index_related_works' do
    context 'work is a specimen' do
      let(:specimen_media) { [media1a, media1b] }
      before do
        allow(specimen).to receive(:index_related)
      end
      context 'organization id is updated' do
        it 'updates related media' do
          skip if !Hyrax.config.index_related_works
          expect(specimen).to receive(:index_related).with(specimen_media)
          specimen.organization_id = [new_organization.id]
          specimen.save
        end
      end
      context 'another attribute is updated' do
        it 'does not update related media' do
          skip if !Hyrax.config.index_related_works
          expect(specimen).not_to receive(:index_related).with(specimen_media)
          specimen.title = ["new title"]
          specimen.save
        end
      end
    end
    context 'work is a cho' do
      let(:cho_media) { [media2a, media2b] }
      before do
        allow(cho).to receive(:index_related)
      end
      context 'organization id is updated' do
        it 'updates related media' do
          skip if !Hyrax.config.index_related_works
          expect(cho).to receive(:index_related).with(cho_media)
          cho.organization_id = [new_organization.id]
          cho.save
        end
      end
      context 'another attribute is updated' do
        it 'does not update related media' do
          skip if !Hyrax.config.index_related_works
          expect(cho).not_to receive(:index_related).with(cho_media)
          cho.title = ["new title"]
          cho.save
        end
      end
    end
    context 'work is an imaging event' do
      let(:ie_media) { [media1a, media1b] }
      before do
        allow(imaging_event1).to receive(:index_related)
      end
      it 'updates related media and objects' do
        skip if !Hyrax.config.index_related_works
        expect(imaging_event1).to receive(:index_related).with(ie_media).and_call_original
        expect(imaging_event1).to receive(:index_related).with([specimen])
        imaging_event1.device_id = [device2.id]
        imaging_event1.ie_modality = ['Photography']
        imaging_event1.save
      end
    end
    context 'work is a media' do
      context 'media represents a specimen' do
        let(:specimen_media)   { media1a }
        before do
          allow(specimen_media).to receive(:index_related)
        end
        it 'updates the related specimen' do
          skip if !Hyrax.config.index_related_works
          expect(specimen_media).to receive(:index_related).with([specimen])
          specimen_media.title = ['new title']
          specimen_media.save
        end
      end
      context 'media represents a cho' do
        let(:cho_media)   { media2a }
        before do
          allow(cho_media).to receive(:index_related)
        end
        it 'updates the related cho' do
          skip if !Hyrax.config.index_related_works
          expect(cho_media).to receive(:index_related).with([cho])

          cho_media.title = ['new title']
          cho_media.save
        end
      end
    end
    context 'work is an organization' do
      let(:media)                   { [media1a, media1b, media2a, media2b] }
      let(:objects)                 { [specimen, cho] }
      let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
      let(:projectA)                { Collection.create(title: ['project A'], collection_type_gid: project_collection_type.gid) }
      let(:projectB)                { Collection.create(title: ['project B'], collection_type_gid: project_collection_type.gid) }
      let(:team_projects)           { [projectA, projectB] }
      before do
        team_projects.each do |p|
          p.member_of_collections << team
          p.save
        end
        allow(organization).to receive(:index_related)
      end
      context 'title is updated' do
        it 'updates related media, objects, linked team, and team child projects' do
          skip if !Hyrax.config.index_related_works
          expect(organization).to receive(:index_related).ordered.with(media).and_call_original
          expect(organization).to receive(:index_related).ordered.with(objects).and_call_original
          expect(organization).to receive(:index_related_collections).ordered.with([team]).and_call_original
          expect(organization).to receive(:index_related_collections).ordered.with(team_projects)

          organization.title = ['new title']
          organization.save
        end
      end
      context 'team_id is updated' do
        let(:projectC)          { Collection.create(title: ['project C'], collection_type_gid: project_collection_type.gid) }
        let(:projectD)          { Collection.create(title: ['project D'], collection_type_gid: project_collection_type.gid) }
        let(:new_team_projects) { [projectC, projectD] }
        before do
          new_team_projects.each do |p|
            p.member_of_collections << new_team
            p.save
          end
        end

        it 'updates its new team, old team, old and new child projects, but not media and objects' do
          skip if !Hyrax.config.index_related_works
          expect(organization).not_to receive(:index_related).with(media).and_call_original
          expect(organization).not_to receive(:index_related).with(objects).and_call_original
          expect(organization).to receive(:index_related_collections).with(a_collection_containing_exactly(team, projectA, projectB)).and_call_original
          expect(organization).to receive(:index_related_collections).with([new_team]).and_call_original
          expect(organization).to receive(:index_related_collections).with(a_collection_containing_exactly(projectC, projectD))
          organization.team_id = [new_team.id]
          organization.save
        end
      end

      context 'another attribute is updated' do
        before do
          allow(organization).to receive(:index_related)
          allow(UpdateRelatedWorksIndexJob).to receive(:perform_later)
        end
        it 'updates related media, objects, and linked team' do
          skip if !Hyrax.config.index_related_works
          expect(organization).not_to receive(:index_related).ordered.with(media).and_call_original
          expect(organization).not_to receive(:index_related).ordered.with(objects).and_call_original
          expect(organization).not_to receive(:index_related).ordered.with(team)

          organization.city = ['Fargo']
          organization.save
        end
      end
    end

    context 'work is a Taxonomy' do
      let(:taxonomy_media)  { [media1a, media1b]}
      before do
        allow(taxonomy).to receive(:index_related)
      end
      context 'title is updated' do
        it 'updates related media and objects' do
          skip if !Hyrax.config.index_related_works
          expect(taxonomy).to receive(:index_related).with([specimen]).and_call_original
          expect(taxonomy).to receive(:index_related).with(taxonomy_media)
          taxonomy.title = ['New Title']
          taxonomy.save
        end
      end
    end
  end
end
