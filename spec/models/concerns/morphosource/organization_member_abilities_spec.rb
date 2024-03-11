# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Morphosource::Ability', type: :model do
  let(:user)                  { FactoryBot.create(:contributor) }
  let(:ability)               { Ability.new(user) }
  let(:media)                 { FactoryBot.create(:media) }
  let(:file_set)              { FactoryBot.create(:file_set) }
  let(:sending_user)          { FactoryBot.create(:contributor) }
  let(:proxy_deposit_request) { ProxyDepositRequest.create(receiving_user_id: organization.id, sending_user_id: sending_user.id, work_id: media.id, status: 'pending' ) }
  let(:depositor)             { FactoryBot.create(:contributor) }
  let(:organization)          { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }

  let(:org_manager)           { FactoryBot.create(:contributor) }
  let(:org_editor)            { FactoryBot.create(:contributor) }
  let(:org_depositor)         { FactoryBot.create(:contributor) }
  let(:org_downloader)        { FactoryBot.create(:registered_user) }
  let(:org_viewer)            { FactoryBot.create(:registered_user) }

  let(:org_members)           { [org_manager, org_editor, org_depositor, org_downloader, org_viewer] }

  before do
    # add fileset to media
    media.ordered_members << file_set
    media.save!
  end

  describe 'organization_member_abilities' do
    context 'the work does not exist' do
      let(:nonexistent_id) { '123' }

      it 'returns false' do
        expect(ability.can? :read, nonexistent_id).to be(false)
        expect(ability.can? :read, nil).to be(false)
      end
    end

    context 'the work is private' do
      context 'the user is not a member of the media organization' do
        before do
          media.owner = organization.id
          media.save!
          allow(user).to receive(:groups).and_return([])
        end

        it 'returns false for read, edit, transfer, accept, and reject' do
          # media
          expect(can_read?(media)).to be(false)
          expect(can_edit?(media)).to be(false)
          expect(can_transfer?(media)).to be(false)
          expect(can_accept?(proxy_deposit_request)).to be(false)
          expect(can_reject?(proxy_deposit_request)).to be(false)

          # file set
          expect(can_read?(file_set)).to be(false)
          expect(can_edit?(file_set)).to be(false)
        end
      end

      context 'the user is a member of the media organization' do
        let(:specimen)      { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
        let(:device)        { FactoryBot.create(:device) }
        let(:imaging_event) { FactoryBot.create(:imaging_event, device_id: [device.id], ie_modality: device.modality, physical_object_id: [specimen.id]) }

        before do
          imaging_event.ordered_members << media
          imaging_event.save!
          media.save!
        end

        context 'the organization is a collection' do
          before do
            # add organization users to groups
            organization.managers << org_manager
            organization.editors << org_editor
            organization.depositors << org_depositor
            organization.downloaders << org_downloader
            organization.viewers << org_viewer
            organization.user_groups.each(&:save)
          end

          context 'the organization is not the data owner' do
            # all organization members can read org media and file sets
            it 'returns the correct permissions for each user' do
              org_members.each do |org_member|
                expect(can_read?(media, org_member)).to be(true)
                expect(can_edit?(media, org_member)).to be(false)
                expect(can_transfer?(media, org_member)).to be(false)
                expect(can_accept?(proxy_deposit_request, org_member)).to be(false)
                expect(can_reject?(proxy_deposit_request, org_member)).to be(false)
                expect(can_read?(file_set, org_member)).to be(true)
                expect(can_edit?(file_set, org_member)).to be(false)
              end
            end
          end

          context 'the organization is the data owner' do
            before do
              media.owner = organization.id
              media.save!
            end

            it 'returns the correct permissions for each member' do
              # manager can read, edit, transfer, accept, reject
              expect(can_read?(media, org_manager)).to be(true)
              expect(can_edit?(media, org_manager)).to be(true)
              expect(can_transfer?(media, org_manager)).to be(true)
              expect(can_accept?(proxy_deposit_request, org_manager)).to be(true)
              expect(can_reject?(proxy_deposit_request, org_manager)).to be(true)
              expect(can_read?(file_set, org_manager)).to be(true)
              expect(can_edit?(file_set, org_manager)).to be(true)
              # editor can read & edit, cannot transfer, accept, reject
              expect(can_read?(media, org_editor)).to be(true)
              expect(can_edit?(media, org_editor)).to be(true)
              expect(can_transfer?(media, org_editor)).to be(false)
              expect(can_accept?(proxy_deposit_request, org_editor)).to be(false)
              expect(can_reject?(proxy_deposit_request, org_editor)).to be(false)
              expect(can_read?(file_set, org_editor)).to be(true)
              expect(can_edit?(file_set, org_editor)).to be(true)
              # depositor, downloader, and viewer can read, cannot edit, transfer, accept, reject
              [org_depositor, org_downloader, org_viewer].each do |member|
                expect(can_read?(media, member)).to be(true)
                expect(can_edit?(media, member)).to be(false)
                expect(can_transfer?(media, member)).to be(false)
                expect(can_accept?(proxy_deposit_request, member)).to be(false)
                expect(can_reject?(proxy_deposit_request, member)).to be(false)
                expect(can_read?(file_set, member)).to be(true)
                expect(can_edit?(file_set, member)).to be(false)
              end
            end
          end
        end

        context 'the organization is a work' do
          let(:organizational_team) { FactoryBot.create(:team, depositor: depositor.ms_id) }
          let(:organization)        { FactoryBot.create(:organization, team_id: [organizational_team.id]) }

          before do
            organizational_team.create_collection_groups
            organizational_team.viewers << user
            organizational_team.viewers_group.save!
          end

          it 'returns true for media and file sets' do
            # media
            expect(can_read?(media)).to be(true)
            # file set
            expect(can_read?(file_set)).to be(true)
          end
        end
      end
    end
  end
end
