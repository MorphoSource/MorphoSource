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

  before do
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
          context 'the organization is not the data owner' do
            context 'the user has a manager role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_managers"])
              end

              it 'returns true for read and false for edit, transfer, accept, and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end

            context 'the user has an editor role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_editors"])
              end

              it 'returns true for read and false for edit, transfer, accept and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end

            context 'the user has a depositor role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_depositors"])
              end

              it 'returns true for read and false for edit, transfer, accept and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end

            context 'the user has a downloader role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_downloaders"])
              end

              it 'returns true for read and false for edit, transfer, accept, and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end

            context 'the user has a viewer role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_viewers"])
              end

              it 'returns true for read and false for edit, transfer, accept, and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end
          end

          context 'the organization is the data owner' do
            before do
              media.owner = organization.id
              media.save!
            end

            context 'the user has a manager role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_managers"])
              end

              it 'returns true for read, edit, transfer, accept, reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(true)
                expect(can_transfer?(media)).to be(true)
                expect(can_accept?(proxy_deposit_request)).to be(true)
                expect(can_reject?(proxy_deposit_request)).to be(true)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(true)
              end
            end

            context 'the user has an editor role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_editors"])
              end

              it 'returns true for read and edit, false for transfer, accept, and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(true)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(true)
              end
            end

            context 'the user has a depositor role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_depositors"])
              end

              it 'returns true for read and false for edit, transfer, accept, and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end

            context 'the user has a downloader role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_downloaders"])
              end

              it 'returns true for read and false for edit, transfer, accept, and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end

            context 'the user has a viewer role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_viewers"])
              end

              it 'returns true for read and false for edit, transfer, accept, and reject' do
                # media
                expect(can_read?(media)).to be(true)
                expect(can_edit?(media)).to be(false)
                expect(can_transfer?(media)).to be(false)
                expect(can_accept?(proxy_deposit_request)).to be(false)
                expect(can_reject?(proxy_deposit_request)).to be(false)
                # file set
                expect(can_read?(file_set)).to be(true)
                expect(can_edit?(file_set)).to be(false)
              end
            end
          end
        end

        #TODO: org team managers can not transfer media
        context 'the organization is a work' do
          let(:organizational_team) { FactoryBot.create(:team) }
          let(:organization)        { FactoryBot.create(:organization, team_id: [organizational_team.id]) }

          before do
            allow(user).to receive(:groups).and_return(["#{organizational_team.id}_viewers"])
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

  def can_read?(work)
    work_doc = SolrDocument.find(work.id)
    result = []
    result << (ability.can? :read, work.id)
    result << (ability.can? :read, work)
    result << (ability.can? :read, work_doc)
    result << (user.can? :read, work.id)
    result << (user.can? :read, work)
    result << (user.can? :read, work_doc)
    return if result.uniq.count > 1

    result.first
  end

  def can_edit?(work)
    work_doc = SolrDocument.find(work.id)
    result = []
    result << (ability.can? :edit, work.id)
    result << (ability.can? :edit, work)
    result << (ability.can? :edit, work_doc)
    result << (user.can? :edit, work.id)
    result << (user.can? :edit, work)
    result << (user.can? :edit, work_doc)
    return if result.uniq.count > 1

    result.first
  end

  def can_transfer?(work)
    result = []
    result << (ability.can? :transfer, work.id)
    result << (user.can? :transfer, work.id)
    return if result.uniq.count > 1

    result.first
  end

  def can_accept?(request)
    result = []
    result << (ability.can? :accept, request)
    result << (user.can? :accept, request)
    return if result.uniq.count > 1

    result.first
  end

  def can_reject?(request)
    result = []
    result << (ability.can? :reject, request)
    result << (user.can? :reject, request)
    return if result.uniq.count > 1

    result.first
  end
end
