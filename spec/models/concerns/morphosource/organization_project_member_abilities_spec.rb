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

  let(:specimen)              { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
  let(:device)                { FactoryBot.create(:device) }
  let(:imaging_event)         { FactoryBot.create(:imaging_event, device_id: [device.id], ie_modality: device.modality, physical_object_id: [specimen.id]) }

  let(:project_manager)       { FactoryBot.create(:contributor) }
  let(:project_editor)        { FactoryBot.create(:contributor) }
  let(:project_depositor)     { FactoryBot.create(:contributor) }
  let(:project_downloader)    { FactoryBot.create(:registered_user) }
  let(:project_viewer)        { FactoryBot.create(:registered_user) }

  let(:project_members)       { [project_manager, project_editor, project_depositor, project_downloader, project_viewer] }

  before do
    imaging_event.ordered_members << media
    imaging_event.save!
    # add fileset to media
    media.ordered_members << file_set
    media.save!
    # create project groups
    project.create_collection_groups
    # add project to organization
    project.member_of_collections << organization
    project.copy_parent_membership(organization.id)
    project.save!

    # add project users to groups
    project.managers << project_manager
    project.editors << project_editor
    project.depositors << project_depositor
    project.downloaders << project_downloader
    project.viewers << project_viewer
    project.user_groups.each(&:save)
  end

  describe 'organization_project_member_abilities' do
    context 'project is an organization subcollection' do
      context 'organization media is not in the project' do
        it 'has the correct permissions for project members' do
          project_members.each do |member|
            member = User.find(member.id)
            expect(member.can?(:read, media)).to be false
            # expect(member.can?(:edit, media)).to be false
            # expect(member.can?(:read, file_set)).to be false
            # expect(member.can?(:edit, file_set)).to be false
            # ability = Ability.new(member)
            # expect(ability.can?(:read, media)).to be false
            # expect(ability.can?(:edit, media)).to be false
            # expect(ability.can?(:read, file_set)).to be false
            # expect(ability.can?(:edit, file_set)).to be false
          end
        end
      end
      context 'organization media is in the project' do
        before do
          project.add_member_objects([media])
        end

        it 'has the correct permissions for project members' do
          [project_manager, project_editor].each do |member|
            member = User.find(member.id)
            expect(member.can?(:read, media)).to be true
            expect(member.can?(:edit, media)).to be true
            expect(member.can?(:read, file_set)).to be true
            expect(member.can?(:edit, file_set)).to be true
            ability = Ability.new(member)
            expect(ability.can?(:read, media)).to be true
            expect(ability.can?(:edit, media)).to be true
            expect(ability.can?(:read, file_set)).to be true
            expect(ability.can?(:edit, file_set)).to be true
          end

          [project_depositor, project_downloader, project_viewer].each do |member|
            expect(member.can?(:read, media)).to be true
            expect(member.can?(:edit, media)).to be false
            expect(member.can?(:read, file_set)).to be true
            expect(member.can?(:edit, file_set)).to be false
            ability = Ability.new(member)
            expect(ability.can?(:read, media)).to be true
            expect(ability.can?(:edit, media)).to be false
            expect(ability.can?(:read, file_set)).to be true
            expect(ability.can?(:edit, file_set)).to be false
          end
        end
      end
    end
  end
end