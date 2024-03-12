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
  let(:project)               { FactoryBot.create(:project, depositor: depositor.ms_id) }

  let(:org_manager)           { FactoryBot.create(:contributor) }
  let(:org_editor)            { FactoryBot.create(:contributor) }
  let(:org_depositor)         { FactoryBot.create(:contributor) }
  let(:org_downloader)        { FactoryBot.create(:registered_user) }
  let(:org_viewer)            { FactoryBot.create(:registered_user) }

  let(:org_members)           { [org_manager, org_editor, org_depositor, org_downloader, org_viewer] }

  # let(:org_manager_ability)   { Ability.new(org_manager) }
  # let(:org_editor_ability)    { Ability.new(org_editor) }
  # let(:org_depositor_ability) { Ability.new(org_depositor) }
  # let(:org_downloader_ability){ Ability.new(org_downloader) }
  # let(:org_viewer_ability)    { Ability.new(org_viewer) }

  let(:project_manager)       { FactoryBot.create(:contributor) }
  let(:project_editor)        { FactoryBot.create(:contributor) }
  let(:project_depositor)     { FactoryBot.create(:contributor) }
  let(:project_downloader)    { FactoryBot.create(:registered_user) }
  let(:project_viewer)        { FactoryBot.create(:registered_user) }

  let(:project_members)       { [project_manager, project_editor, project_depositor, project_downloader, project_viewer] }

  # let(:project_manager_ability)   { Ability.new(project_manager) }
  # let(:project_editor_ability)    { Ability.new(project_editor) }
  # let(:project_depositor_ability) { Ability.new(project_depositor) }
  # let(:project_downloader_ability){ Ability.new(project_downloader) }
  # let(:project_viewer_ability)    { Ability.new(project_viewer) }

  before do
    # add fileset to media
    media.ordered_members << file_set
    media.save!
    # create project groups
    project.create_collection_groups
    # add project to organization
    project.member_of_collections << organization
    project.copy_parent_membership(organization.id)
    project.save!

    # add organization users to groups
    organization.managers << org_manager
    organization.editors << org_editor
    organization.depositors << org_depositor
    organization.downloaders << org_downloader
    organization.viewers << org_viewer
    organization.user_groups.each(&:save)

    # add project users to groups
    project.managers << project_manager
    project.editors << project_editor
    project.depositors << project_depositor
    project.downloaders << project_downloader
    project.viewers << project_viewer
    project.user_groups.each(&:save)
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
            # all organization members can read org media and file sets
            it 'returns the correct permissions for each user' do
              org_members.each do |org_member|
                expect(can_read?(org_member, media)).to be(true)
                expect(can_edit?(org_member, media)).to be(false)
                expect(can_transfer?(org_member, media)).to be(false)
                expect(can_accept?(org_member, proxy_deposit_request)).to be(false)
                expect(can_reject?(org_member, proxy_deposit_request)).to be(false)
                expect(can_read?(org_member, file_set)).to be(true)
                expect(can_edit?(org_member, file_set)).to be(false)
              end
            end

            context 'the media is added to an organization project' do
              before do
                media.member_of_collections << project
                media.save!
              end

              it 'returns the correct permissions for each user' do
                # org members org membership is copied to the project
                # org and project managers can read & edit, cannot transfer, accept, reject
                byebug
                [org_manager, project_manager].each do |manager|
                  expect(can_read?(manager, media)).to be(true)
                  expect(can_edit?(manager, media)).to be(true)
                  expect(can_transfer?(manager, media)).to be(false)
                  expect(can_accept?(manager, proxy_deposit_request)).to be(false)
                  expect(can_reject?(manager, proxy_deposit_request)).to be(false)
                  expect(can_read?(manager, file_set)).to be(true)
                  expect(can_edit?(manager, file_set)).to be(true)
                end
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
              expect(can_read?(org_manager, media)).to be(true)
              expect(can_edit?(org_manager, media)).to be(true)
              expect(can_transfer?(org_manager, media)).to be(true)
              expect(can_accept?(org_manager, proxy_deposit_request)).to be(true)
              expect(can_reject?(org_manager, proxy_deposit_request)).to be(true)
              expect(can_read?(org_manager, file_set)).to be(true)
              expect(can_edit?(org_manager, file_set)).to be(true)
              # editor can read & edit, cannot transfer, accept, reject
              expect(can_read?(org_editor, media)).to be(true)
              expect(can_edit?(org_editor, media)).to be(true)
              expect(can_transfer?(org_editor, media)).to be(false)
              expect(can_accept?(org_editor, proxy_deposit_request)).to be(false)
              expect(can_reject?(org_editor, proxy_deposit_request)).to be(false)
              expect(can_read?(org_editor, file_set)).to be(true)
              expect(can_edit?(org_editor, file_set)).to be(true)
              # depositor, downloader, and viewer can read, cannot edit, transfer, accept, reject
              [org_depositor, org_downloader, org_viewer].each do |member|
                expect(can_read?(member, media)).to be(true)
                expect(can_edit?(member, media)).to be(false)
                expect(can_transfer?(member, media)).to be(false)
                expect(can_accept?(member, proxy_deposit_request)).to be(false)
                expect(can_reject?(member, proxy_deposit_request)).to be(false)
                expect(can_read?(member, file_set)).to be(true)
                expect(can_edit?(member, file_set)).to be(false)
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

  def can_read?(user, work)
    user = User.find(user.id)
    ability = Ability.new(user)
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

  def can_edit?(user, work)
    user = User.find(user.id)
    ability = Ability.new(user)
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

  def can_transfer?(user, work)
    user = User.find(user.id)
    ability = Ability.new(user)
    result = []
    result << (ability.can? :transfer, work.id)
    result << (user.can? :transfer, work.id)
    return if result.uniq.count > 1

    result.first
  end

  def can_accept?(user, request)
    user = User.find(user.id)
    ability = Ability.new(user)
    result = []
    result << (ability.can? :accept, request)
    result << (user.can? :accept, request)
    return if result.uniq.count > 1

    result.first
  end

  def can_reject?(user, request)
    user = User.find(user.id)
    ability = Ability.new(user)
    result = []
    result << (ability.can? :reject, request)
    result << (user.can? :reject, request)
    return if result.uniq.count > 1

    result.first
  end
end
