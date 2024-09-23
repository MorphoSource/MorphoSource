# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Morphosource::Ability', type: :model do
  let(:user)                  { User.create(email: 'user@email.com', password: 'password') }
  let(:ability)               { Ability.new(user) }
  let!(:depositor)            { FactoryBot.create(:contributor) }
  let(:organization)          { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }

  let(:org_manager)           { User.create(email: 'manager@email.com', password: 'password') }
  let(:org_editor)            { User.create(email: 'editor@email.com', password: 'password') }
  let(:org_depositor)         { User.create(email: 'depositor@email.com', password: 'password') }
  let(:org_downloader)        { User.create(email: 'downloader@email.com', password: 'password') }
  let(:org_viewer)            { User.create(email: 'viewer@email.com', password: 'password') }

  let(:org_members)           { [org_manager, org_editor, org_depositor, org_downloader, org_viewer] }
  let(:org_read_members)      { [org_manager, org_editor, org_downloader, org_viewer] }

  let(:specimen)              { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
  let(:device)                { FactoryBot.create(:device) }
  let(:imaging_event)         { FactoryBot.create(:imaging_event, physical_object_id: [specimen.id], device_id: [device.id], ie_modality: ['Photogrammetry'], visibility: 'restricted') }
  let(:processing_event)      { FactoryBot.create(:processing_event, visibility: 'restricted') }
  let(:top_media)             { FactoryBot.create(:media) }
  let(:file_set)              { FactoryBot.create(:file_set) }
  let(:processing_event2)     { FactoryBot.create(:processing_event, visibility: 'restricted') }
  let(:child_media)           { FactoryBot.create(:media) }
  let(:file_set2)             { FactoryBot.create(:file_set) }


  describe 'imaging_event_abilities' do
    # Imaging Event
    #   - Processing Event
    #     - Top Media
    #       - File Set
    #       - Processing Event 2
    #         - Child Media
    #           - File Set 2

    context 'with media that is private and is associated with org through object' do
      before do
        imaging_event.ordered_members << processing_event
        processing_event.ordered_members << top_media
        top_media.ordered_members << file_set << processing_event2
        processing_event2.ordered_members << child_media
        child_media.ordered_members << file_set2
        [imaging_event, processing_event, top_media, processing_event2, child_media].each(&:save!)
      end

      context 'the user is not a member of the media object organization' do
        before do
          allow(user).to receive(:groups).and_return([])
        end

        it 'returns false for read, edit, and update' do
          # imaging event
          expect(user.can?(:read, imaging_event)).to be(false)
          expect(user.can?(:edit, imaging_event)).to be(false)
          expect(user.can?(:update, imaging_event)).to be(false)
          # processing event
          expect(user.can?(:read, processing_event)).to be(false)
          expect(user.can?(:edit, processing_event)).to be(false)
          expect(user.can?(:update, processing_event)).to be(false)
          # processing event 2
          expect(user.can?(:read, processing_event2)).to be(false)
          expect(user.can?(:edit, processing_event2)).to be(false)
          expect(user.can?(:update, processing_event2)).to be(false)
        end
      end

      context 'the user is a member of the media organization' do
        context 'the organization is a collection' do
          before do
            [org_manager, org_editor, org_depositor].each(&:make_contributor)
            [org_manager, org_editor, org_depositor].each(&:reload)
            # add organization users to groups
            organization.managers << org_manager
            organization.editors << org_editor
            organization.depositors << org_depositor
            organization.downloaders << org_downloader
            organization.viewers << org_viewer
            organization.user_groups.each(&:save)
          end

          context 'the organization is not the data owner' do
            it 'managers, editors, downloaders, and viewers can read but not edit or update the events; depositors can not read, edit, or update' do
              org_read_members.each do |org_member|
                # imaging event
                expect(can_read?(imaging_event, org_member)).to be(true)
                expect(can_edit?(imaging_event, org_member)).to be(false)
                expect(can_update?(imaging_event, org_member)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_member)).to be(true)
                expect(can_edit?(processing_event, org_member)).to be(false)
                expect(can_update?(processing_event, org_member)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_member)).to be(true)
                expect(can_edit?(processing_event2, org_member)).to be(false)
                expect(can_update?(processing_event2, org_member)).to be(false)
              end
              # depositor can't do anything
              # imaging_event
              expect(can_read?(imaging_event, org_depositor)).to be(false)
              expect(can_edit?(imaging_event, org_depositor)).to be(false)
              expect(can_update?(imaging_event, org_depositor)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_depositor)).to be(false)
              expect(can_edit?(processing_event, org_depositor)).to be(false)
              expect(can_update?(processing_event, org_depositor)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_depositor)).to be(false)
              expect(can_edit?(processing_event2, org_depositor)).to be(false)
              expect(can_update?(processing_event2, org_depositor)).to be(false)
            end
          end

          context 'the organization is the data owner of the top media' do
            before do
              top_media.owner = organization.id
              top_media.save!
              top_media.reload
            end

            it 'returns the correct permissions for manager member' do
              # manager can read, edit, update imaging_event, processing_event
              # manager can read but not edit, update processing_event2
              # imaging event
              expect(can_read?(imaging_event, org_manager)).to be(true)
              expect(can_edit?(imaging_event, org_manager)).to be(true)
              expect(can_update?(imaging_event, org_manager)).to be(true)
              # processing event
              expect(can_read?(processing_event, org_manager)).to be(true)
              expect(can_edit?(processing_event, org_manager)).to be(true)
              expect(can_update?(processing_event, org_manager)).to be(true)
              # processing event 2
              expect(can_read?(processing_event2, org_manager)).to be(true)
              expect(can_edit?(processing_event2, org_manager)).to be(false)
              expect(can_update?(processing_event2, org_manager)).to be(false)
            end

            it 'returns the correct permissions for editor member' do
              # editor can edit, update imaging_event, processing_event
              # editor can read processing_event2
              # imaging event
              expect(can_read?(imaging_event, org_editor)).to be(true)
              expect(can_edit?(imaging_event, org_editor)).to be(true)
              expect(can_update?(imaging_event, org_editor)).to be(true)
              # processing event
              expect(can_read?(processing_event, org_editor)).to be(true)
              expect(can_edit?(processing_event, org_editor)).to be(true)
              expect(can_update?(processing_event, org_editor)).to be(true)
              # processing event 2
              expect(can_read?(processing_event2, org_editor)).to be(true)
              expect(can_edit?(processing_event2, org_editor)).to be(false)
              expect(can_update?(processing_event2, org_editor)).to be(false)
            end

            it 'returns the correct permissions for depositor member' do
              # depositor can't do anything
              # imaging_event
              expect(can_read?(imaging_event, org_depositor)).to be(false)
              expect(can_edit?(imaging_event, org_depositor)).to be(false)
              expect(can_update?(imaging_event, org_depositor)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_depositor)).to be(false)
              expect(can_edit?(processing_event, org_depositor)).to be(false)
              expect(can_update?(processing_event, org_depositor)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_depositor)).to be(false)
              expect(can_edit?(processing_event2, org_depositor)).to be(false)
              expect(can_update?(processing_event2, org_depositor)).to be(false)
            end

            it 'returns the correct permissions for downloader' do
              # downloader can read all records
              # downloader can't edit or update any records
              # imaging_event
              expect(can_read?(imaging_event, org_downloader)).to be(true)
              expect(can_edit?(imaging_event, org_downloader)).to be(false)
              expect(can_update?(processing_event2, org_depositor)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_downloader)).to be(true)
              expect(can_edit?(processing_event, org_downloader)).to be(false)
              expect(can_update?(processing_event, org_downloader)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_downloader)).to be(true)
              expect(can_edit?(processing_event2, org_downloader)).to be(false)
              expect(can_update?(processing_event2, org_downloader)).to be(false)
            end

            it 'returns the correct permissions for viewer' do
              # viewer can read all records
              # viewer can't edit or update any records
              # imaging_event
              expect(can_read?(imaging_event, org_viewer)).to be(true)
              expect(can_edit?(imaging_event, org_viewer)).to be(false)
              expect(can_update?(imaging_event, org_viewer)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_viewer)).to be(true)
              expect(can_edit?(processing_event, org_viewer)).to be(false)
              expect(can_update?(processing_event, org_viewer)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_viewer)).to be(true)
              expect(can_edit?(processing_event2, org_viewer)).to be(false)
              expect(can_update?(processing_event2, org_viewer)).to be(false)
            end

            context 'edge case - the top media is owned by the organization but is not otherwise associated with the organization' do
              let(:specimen)  { FactoryBot.create(:biological_specimen) }

              it 'returns the correct permissions for manager member' do
                # manager can read, edit, and update imaging_event, processing_event
                # manager can not read, edit, or update processing_event2
                # imaging event
                expect(can_read?(imaging_event, org_manager)).to be(true)
                expect(can_edit?(imaging_event, org_manager)).to be(true)
                expect(can_update?(imaging_event, org_manager)).to be(true)
                # processing event
                expect(can_read?(processing_event, org_manager)).to be(true)
                expect(can_edit?(processing_event, org_manager)).to be(true)
                expect(can_update?(processing_event, org_manager)).to be(true)
                # processing event 2
                expect(can_read?(processing_event2, org_manager)).to be(false)
                expect(can_edit?(processing_event2, org_manager)).to be(false)
                expect(can_update?(processing_event2, org_manager)).to be(false)
              end

              it 'returns the correct permissions for editor member' do
                # editor can read, edit, and update imaging_event, processing_event
                # editor can not read, edit, or update processing_event2
                # imaging event
                expect(can_read?(imaging_event, org_editor)).to be(true)
                expect(can_edit?(imaging_event, org_editor)).to be(true)
                expect(can_update?(imaging_event, org_editor)).to be(true)
                # processing event
                expect(can_read?(processing_event, org_editor)).to be(true)
                expect(can_edit?(processing_event, org_editor)).to be(true)
                expect(can_update?(processing_event, org_editor)).to be(true)
                # processing event 2
                expect(can_read?(processing_event2, org_editor)).to be(false)
                expect(can_edit?(processing_event2, org_editor)).to be(false)
                expect(can_update?(processing_event2, org_editor)).to be(false)
              end

              it 'returns the correct permissions for depositor member' do
                # depositor can't do anything
                # imaging event
                expect(can_read?(imaging_event, org_depositor)).to be(false)
                expect(can_edit?(imaging_event, org_depositor)).to be(false)
                expect(can_update?(imaging_event, org_depositor)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_depositor)).to be(false)
                expect(can_edit?(processing_event, org_depositor)).to be(false)
                expect(can_update?(processing_event, org_depositor)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_depositor)).to be(false)
                expect(can_edit?(processing_event2, org_depositor)).to be(false)
                expect(can_update?(processing_event2, org_depositor)).to be(false)
              end

              it 'returns the correct permissions for downloader' do
                # downloader can read imaging_event, processing_event
                # downloader can not read processing_event2
                # downloader can not edit, update any records
                # imaging event
                expect(can_read?(imaging_event, org_downloader)).to be(true)
                expect(can_edit?(imaging_event, org_downloader)).to be(false)
                expect(can_update?(imaging_event, org_downloader)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_downloader)).to be(true)
                expect(can_edit?(processing_event, org_downloader)).to be(false)
                expect(can_update?(processing_event, org_downloader)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_downloader)).to be(false)
                expect(can_edit?(processing_event2, org_downloader)).to be(false)
                expect(can_update?(processing_event2, org_downloader)).to be(false)
              end

              it 'returns the correct permissions for viewer' do
                # viewer can read imaging_event, processing_event
                # viewer can not read processing_event2
                # viewer can not edit, update any records
                # imaging event
                expect(can_read?(imaging_event, org_viewer)).to be(true)
                expect(can_edit?(imaging_event, org_viewer)).to be(false)
                expect(can_update?(imaging_event, org_viewer)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_viewer)).to be(true)
                expect(can_edit?(processing_event, org_viewer)).to be(false)
                expect(can_update?(processing_event, org_viewer)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_viewer)).to be(false)
                expect(can_edit?(processing_event2, org_viewer)).to be(false)
                expect(can_update?(processing_event2, org_viewer)).to be(false)
              end
            end
          end

          context 'the organization is the data owner of the child media' do
            before do
              child_media.owner = organization.id
              child_media.save!
              child_media.reload
            end

            it 'returns the correct permissions for manager member' do
              # manager can read but not edit or udpate imaging_event, processing_event
              # manager can read, edit, and update processing_event2
              # imaging event
              expect(can_read?(imaging_event, org_manager)).to be(true)
              expect(can_edit?(imaging_event, org_manager)).to be(false)
              expect(can_update?(imaging_event, org_manager)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_manager)).to be(true)
              expect(can_edit?(processing_event, org_manager)).to be(false)
              expect(can_update?(processing_event, org_manager)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_manager)).to be(true)
              expect(can_edit?(processing_event2, org_manager)).to be(true)
              expect(can_update?(processing_event2, org_manager)).to be(true)
            end

            it 'returns the correct permissions for editor member' do
              # editor can read but not edit or update imaging_event, processing_event
              # editor can edit and update processing_event2
              # imaging event
              expect(can_read?(imaging_event, org_editor)).to be(true)
              expect(can_edit?(imaging_event, org_editor)).to be(false)
              expect(can_update?(imaging_event, org_editor)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_editor)).to be(true)
              expect(can_edit?(processing_event, org_editor)).to be(false)
              expect(can_update?(processing_event, org_editor)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_editor)).to be(true)
              expect(can_edit?(processing_event2, org_editor)).to be(true)
              expect(can_update?(processing_event2, org_editor)).to be(true)
            end

            it 'returns the correct permissions for depositor member' do
              # depositor can't do anything
              # imaging_event
              expect(can_read?(imaging_event, org_depositor)).to be(false)
              expect(can_edit?(imaging_event, org_depositor)).to be(false)
              expect(can_update?(imaging_event, org_depositor)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_depositor)).to be(false)
              expect(can_edit?(processing_event, org_depositor)).to be(false)
              expect(can_update?(processing_event, org_depositor)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_depositor)).to be(false)
              expect(can_edit?(processing_event2, org_depositor)).to be(false)
              expect(can_update?(processing_event2, org_depositor)).to be(false)
            end

            it 'returns the correct permissions for downloader' do
              # downloader can read all records
              # downloader can't edit or update any records
              # imaging_event
              expect(can_read?(imaging_event, org_downloader)).to be(true)
              expect(can_edit?(imaging_event, org_downloader)).to be(false)
              expect(can_update?(imaging_event, org_downloader)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_downloader)).to be(true)
              expect(can_edit?(processing_event, org_downloader)).to be(false)
              expect(can_update?(processing_event, org_downloader)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_downloader)).to be(true)
              expect(can_edit?(processing_event2, org_downloader)).to be(false)
              expect(can_update?(processing_event2, org_downloader)).to be(false)
            end

            it 'returns the correct permissions for viewer' do
              # viewer can read all records
              # viewer can't edit or update any records
              # imaging_event
              expect(can_read?(imaging_event, org_viewer)).to be(true)
              expect(can_edit?(imaging_event, org_viewer)).to be(false)
              expect(can_update?(imaging_event, org_viewer)).to be(false)
              # processing event
              expect(can_read?(processing_event, org_viewer)).to be(true)
              expect(can_edit?(processing_event, org_viewer)).to be(false)
              expect(can_update?(processing_event, org_viewer)).to be(false)
              # processing event 2
              expect(can_read?(processing_event2, org_viewer)).to be(true)
              expect(can_edit?(processing_event2, org_viewer)).to be(false)
              expect(can_update?(processing_event2, org_viewer)).to be(false)
            end

            context 'edge case - the child media is owned by the organization but is not otherwise associated with the organization' do
              let(:specimen)  { FactoryBot.create(:biological_specimen) }

              it 'returns the correct permissions for manager member' do
                # manager can not read, edit, or update imaging_event, processing_event
                # manager can read, edit, and update processing_event2
                # imaging event
                expect(can_read?(imaging_event, org_manager)).to be(false)
                expect(can_edit?(imaging_event, org_manager)).to be(false)
                expect(can_update?(imaging_event, org_manager)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_manager)).to be(false)
                expect(can_edit?(processing_event, org_manager)).to be(false)
                expect(can_update?(processing_event, org_manager)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_manager)).to be(true)
                expect(can_edit?(processing_event2, org_manager)).to be(true)
                expect(can_update?(processing_event2, org_manager)).to be(true)
              end

              it 'returns the correct permissions for editor member' do
                # editor can not read, edit, or update imaging_event, processing_event
                # editor can read, edit, and update processing_event2
                # imaging event
                expect(can_read?(imaging_event, org_editor)).to be(false)
                expect(can_edit?(imaging_event, org_editor)).to be(false)
                expect(can_update?(imaging_event, org_editor)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_editor)).to be(false)
                expect(can_edit?(processing_event, org_editor)).to be(false)
                expect(can_update?(processing_event, org_editor)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_editor)).to be(true)
                expect(can_edit?(processing_event2, org_editor)).to be(true)
                expect(can_update?(processing_event2, org_editor)).to be(true)
              end

              it 'returns the correct permissions for depositor member' do
                # depositor can't do anything
                # imaging event
                expect(can_read?(imaging_event, org_depositor)).to be(false)
                expect(can_edit?(imaging_event, org_depositor)).to be(false)
                expect(can_update?(imaging_event, org_depositor)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_depositor)).to be(false)
                expect(can_edit?(processing_event, org_depositor)).to be(false)
                expect(can_update?(processing_event, org_depositor)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_depositor)).to be(false)
                expect(can_edit?(processing_event2, org_depositor)).to be(false)
                expect(can_update?(processing_event2, org_depositor)).to be(false)
              end

              it 'returns the correct permissions for downloader' do
                # downloader can not read, edit, or update imaging_event, processing_event
                # downloader can read but not edit or update processing_event2
                # imaging event
                expect(can_read?(imaging_event, org_downloader)).to be(false)
                expect(can_edit?(imaging_event, org_downloader)).to be(false)
                expect(can_update?(imaging_event, org_downloader)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_downloader)).to be(false)
                expect(can_edit?(processing_event, org_downloader)).to be(false)
                expect(can_update?(processing_event, org_downloader)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_downloader)).to be(true)
                expect(can_edit?(processing_event2, org_downloader)).to be(false)
                expect(can_update?(processing_event2, org_downloader)).to be(false)
              end

              it 'returns the correct permissions for viewer' do
                # viewer can not read, edit, or update imaging_event, processing_event
                # viewer can read but not edit or update processing_event2
                # imaging event
                expect(can_read?(imaging_event, org_viewer)).to be(false)
                expect(can_edit?(imaging_event, org_viewer)).to be(false)
                expect(can_update?(imaging_event, org_viewer)).to be(false)
                # processing event
                expect(can_read?(processing_event, org_viewer)).to be(false)
                expect(can_edit?(processing_event, org_viewer)).to be(false)
                expect(can_update?(processing_event, org_viewer)).to be(false)
                # processing event 2
                expect(can_read?(processing_event2, org_viewer)).to be(true)
                expect(can_edit?(processing_event2, org_viewer)).to be(false)
                expect(can_update?(processing_event2, org_viewer)).to be(false)
              end
            end
          end
        end
      end
    end
  end

  describe 'detect_child_media' do
    let(:media)     { FactoryBot.create(:media) }
    let(:event_doc) { SolrDocument.find(event.id) }
    context 'event is an imaging event' do
      let(:event)     { imaging_event }
      context 'imaging event has no child media' do
        context 'imaging event has no child works' do
          it 'returns nil' do
            expect(ability.send(:detect_child_media, event_doc)).to eq([])
          end
        end
        context 'imaging event has a processing event with no child media' do
          before do
            event.ordered_members << processing_event
            event.save!
          end
          it 'returns nil' do
            expect(ability.send(:detect_child_media, event_doc)).to eq([])
          end
        end
        context 'imaging event has multiple processing events with no child media' do
          let(:processing_event2) { FactoryBot.create(:processing_event) }
          before do
            event.ordered_members << processing_event
            event.ordered_members << processing_event2
            event.save!
          end
          it 'returns nil' do
            expect(ability.send(:detect_child_media, event_doc)).to eq([])
          end
        end
      end
      context 'imaging event has a child media' do
        context 'imaging event has a direct child media' do
          before do
            event.ordered_members << media
            event.save!
          end

          it 'returns the child media' do
            expect(ability.send(:detect_child_media, event_doc).map{|doc| doc['id']}).to match_array([media.id])
          end
        end
        context 'imaging event has a processing event with a child media' do
          before do
            event.ordered_members << processing_event
            event.save!
            processing_event.ordered_members << media
            processing_event.save!
          end

          it 'returns the child media' do
            expect(ability.send(:detect_child_media, event_doc).map{|doc| doc['id']}).to match_array([media.id])
          end
        end

        context 'imaging event has multiple processing events with child media' do
          let(:processing_event2)  { FactoryBot.create(:processing_event) }
          let(:media2)             { FactoryBot.create(:media) }

          before do
            event.ordered_members << processing_event
            event.ordered_members << processing_event2
            event.save!
            processing_event.ordered_members << media
            processing_event.save!
            processing_event2.ordered_members << media2
            processing_event2.save!
          end

          it 'returns the child media' do
            expect(ability.send(:detect_child_media, event_doc).map{|d| d['id']}).to match_array([media.id, media2.id])
          end
        end
      end
    end
    context 'event is a processing event' do
      let(:event)     { processing_event }

      context 'processing event has no child media' do
        context 'processing event has no child works' do
          it 'returns nil' do
            expect(ability.send(:detect_child_media, event_doc)).to eq([])
          end
        end
      end
      context 'processing event has a child media' do
        before do
          event.ordered_members << media
          event.save!
        end

        it 'returns the child media' do
          expect(ability.send(:detect_child_media, event_doc).map{|doc| doc['id']}).to match_array([media.id])
        end
      end
    end
  end
end
