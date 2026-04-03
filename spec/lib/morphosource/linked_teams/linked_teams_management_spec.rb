require 'rails_helper'
RSpec.describe Morphosource::LinkedTeams::LinkedTeamsManagement do

  describe '#new_processing_event_media_updates' do
    let(:subject)               { SubmissionsController.new() }
    let(:user)                  { User.create(email: 'email@email.com', password: 'password') }
    let(:team)                  { Collection.create(title: ['New Team'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
    let(:old_team)              { Collection.create(title: ['Old Team'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
    let(:organization)          { Organization.create(title: ['new organization']) }
    let(:old_organization)      { Organization.create(title: ['old organization'], team_id: [old_team.id]) }
    let(:specimen)              { BiologicalSpecimen.create(title: ['new specimen'], vouchered: ["Yes"], organization_id: [organization.id]) }
    let(:old_specimen)          { BiologicalSpecimen.create(title: ['old_specimen'], vouchered: ["Yes"], organization_id: [old_organization.id]) }
    let(:device)                { FactoryBot.valkyrie_create(:device_resource, title: ['title'], modality: ['Photogrammetry'])}
    let(:imaging_event)         { ImagingEvent.create(title: ['new imaging event'], device_id: [device.id.to_s], physical_object_id: [specimen.id], ie_modality: device.modality) }
    let(:old_imaging_event)     { ImagingEvent.create(title: ['old imaging event'], device_id: [device.id.to_s], physical_object_id: [old_specimen.id], ie_modality: device.modality) }
    let(:processing_event)      { ProcessingEvent.create(title: ['new processing event']) }
    let(:child_processing_event){ ProcessingEvent.create(title: ['child processing event']) }
    let(:media)                 { Media.create(title: ['media'], media_type: ['Image']) }
    let(:child_media)           { Media.create(title: ['child media'], media_type: ['Image']) }

    before do
      # set up work relationships
      imaging_event.ordered_members << processing_event
      processing_event.ordered_members << media
      media.ordered_members << child_processing_event
      child_processing_event.ordered_members << child_media
      # save all works
      works = [imaging_event, processing_event, media, child_processing_event, child_media]
      works.each(&:save)
      works.each(&:reload)
    end

    context 'new organization does not have a linked team' do
      context 'child media does not have a linked team' do
        before do
          subject.new_processing_event_updates(media)
        end
        it "does not change the media's permissions" do

          expect(media.read_groups).to match_array([])
          expect(child_media.read_groups).to match_array([])
        end
      end
      context 'child media has a linked team' do
        before do
          old_team.create_collection_groups
          media.read_groups += old_team.user_groups_names
          child_media.read_groups += old_team.user_groups_names

          old_imaging_event.ordered_members << media

          works = [old_imaging_event, media, child_media]
          works.each(&:save)
          works.each(&:reload)

          subject.new_processing_event_updates(media)
        end
        it "does not change the media's permissions" do
          expect(media.read_groups).to match_array(old_team.user_groups_names)
          expect(child_media.read_groups).to match_array(old_team.user_groups_names)
        end
      end
    end
    context 'new organization has a linked team' do
      before do
        team.create_collection_groups
        organization.team_id = [team.id]
        organization.save
      end
      context 'child media does not have a linked team' do
        before do
          subject.new_processing_event_updates(media)
        end
        it 'adds read access for the new team' do
          expect(media.read_groups).to match_array(team.user_groups_names)
          expect(child_media.read_groups).to match_array(team.user_groups_names)
        end
      end
      context 'child media has a linked team' do
        before do
          old_team.create_collection_groups
          media.read_groups += old_team.user_groups_names
          child_media.read_groups += old_team.user_groups_names

          old_imaging_event.ordered_members << media

          works = [old_imaging_event, media, child_media]
          works.each(&:save)
          works.each(&:reload)

          subject.new_processing_event_updates(media)
        end
        it 'keeps permissions for the previous team and adds read access for the new team' do
          expect(media.read_groups).to match_array(team.user_groups_names + old_team.user_groups_names)
          expect(child_media.read_groups).to match_array(team.user_groups_names + old_team.user_groups_names)
        end
      end
    end
  end
end
