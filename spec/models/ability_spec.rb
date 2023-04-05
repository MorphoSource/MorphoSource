require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do

  let(:user)                         { FactoryBot.build(:registered_user) }
  let(:contributor)                  { FactoryBot.build(:contributor) }
  let(:admin)                        { FactoryBot.build(:admin) }
  let(:guest)                        { FactoryBot.build(:user, :guest) }
  let(:batch_submission_contributor) { FactoryBot.build(:batch_submission_contributor) }

  let(:user_ability)                         { Ability.new(user) }
  let(:contributor_ability)                  { Ability.new(contributor) }
  let(:admin_ability)                        { Ability.new(admin) }
  let(:guest_ability)                        { Ability.new(guest) }
  let(:batch_submission_contributor_ability) { Ability.new(batch_submission_contributor) }

  describe 'Submissions user abilities' do
    let(:submission_actions) { [ :new, :create, :stage_biological_specimen, :stage_biological_specimen_from_idigbio, :stage_cultural_heritage_object, :stage_device, :stage_imaging_event, :stage_organization, :stage_device_organization, :stage_media, :stage_processing_event, :stage_cho, :stage_taxonomy, :new_organization, :new_taxonomy, :new_taxonomy_submit, :new_processing_event_submit ] }

    it 'denies registered users and guests, authorizes admins and contributors' do
      submission_actions.each do |action|
        expect(admin_ability).to be_able_to(action, Submission)
        expect(contributor_ability).to be_able_to(action, Submission)
        expect(user_ability).not_to be_able_to(action, Submission)
        expect(guest_ability).not_to be_able_to(action, Submission)
      end
    end
  end

  describe 'BackgroundJob user abilities' do
    it 'only batch submission contributors and admins can :index BackgroundJob' do
      expect(admin_ability).to be_able_to(:index, BackgroundJob)
      expect(batch_submission_contributor_ability).to be_able_to(:index, BackgroundJob)
      expect(contributor_ability).not_to be_able_to(:index, BackgroundJob)
      expect(user_ability).not_to be_able_to(:index, BackgroundJob)
      expect(guest_ability).not_to be_able_to(:index, BackgroundJob)
    end

    it 'only admins can :manage BackgroundJob' do
      expect(admin_ability).to be_able_to(:manage, BackgroundJob)
      expect(contributor_ability).not_to be_able_to(:manage, BackgroundJob)
      expect(user_ability).not_to be_able_to(:manage, BackgroundJob)
      expect(guest_ability).not_to be_able_to(:manage, BackgroundJob)
    end
  end

  describe 'Fedora user abilities' do
    context 'when creating new objects' do

      it 'denies registered users and guests, authorizes admins and contributors' do
        expect(user_ability).not_to be_able_to(:create, ActiveFedora::Base)
        expect(admin_ability).to be_able_to(:create, ActiveFedora::Base)
        expect(contributor_ability).to be_able_to(:create, ActiveFedora::Base)
        expect(guest_ability).not_to be_able_to(:create, ActiveFedora::Base)
      end
    end
  end

  describe 'Showcase user abilities' do
    context 'works' do
      context 'work is public' do
        let!(:public_media)     { Media.create(title: ['Public Media'], visibility: 'open') }
        let!(:public_specimen)  { BiologicalSpecimen.create(title: ['Public Specimen'], vouchered: ['Yes'], visibility: 'open') }
        let(:public_cho)       { CulturalHeritageObject.create(title: ['Private CHO'], vouchered: ['Yes'], visibility: 'open') }

        it 'authorizes admins, contributors, registered users, and guests' do
          expect(admin_ability).to be_able_to(:read, public_media)
          expect(user_ability).to be_able_to(:read, public_media)
          expect(guest_ability).to be_able_to(:read, public_media)

          expect(admin_ability).to be_able_to(:read, public_specimen)
          expect(user_ability).to be_able_to(:read, public_specimen)
          expect(guest_ability).to be_able_to(:read, public_specimen)

          expect(admin_ability).to be_able_to(:read, public_cho)
          expect(user_ability).to be_able_to(:read, public_cho)
          expect(guest_ability).to be_able_to(:read, public_cho)
        end
      end

      context 'work is private' do
        let(:private_media)     { Media.create(title: ['Private Media'], visibility: 'restricted') }
        let(:private_specimen)  { BiologicalSpecimen.create(title: ['Private Specimen'], vouchered: ['Yes'], visibility: 'restricted') }
        let(:private_cho)       { CulturalHeritageObject.create(title: ['Private CHO'], vouchered: ['Yes'], visibility: 'restricted') }

        it 'denies registered users, and guests, authorizes admins' do
          expect(admin_ability).to be_able_to(:read, private_media)
          expect(user_ability).not_to be_able_to(:read, private_media)
          expect(guest_ability).not_to be_able_to(:read, private_media)

          expect(admin_ability).to be_able_to(:read, private_specimen)
          expect(user_ability).not_to be_able_to(:read, private_specimen)
          expect(guest_ability).not_to be_able_to(:read, private_specimen)

          expect(admin_ability).to be_able_to(:read, private_cho)
          expect(user_ability).not_to be_able_to(:read, private_cho)
          expect(guest_ability).not_to be_able_to(:read, private_cho)
        end
      end
    end
    context 'collections' do
      let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }

      let(:team_collection_type)                    { Hyrax::CollectionType.create(title: 'Team') }
      let(:project_collection_type)                 { Hyrax::CollectionType.create(title: 'Project') }
      let(:media_list_collection_type)              { Hyrax::CollectionType.create(title: 'Media List') }
      let(:sequential_section_list_collection_type) { Hyrax::CollectionType.create(title: 'Sequential Section List') }

      let(:team)                    { Collection.new(title: ['team'], collection_type_gid: team_collection_type.gid, depositor: depositor.ms_id) }
      let(:project)                 { Collection.new(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
      let(:media_list)              { MediaList.new(title: ['media list'], visibility: 'open', collection_type_gid: media_list_collection_type.gid, depositor: depositor.ms_id) }
      let(:sequential_section_list) { SequentialSectionList.new(title: ['sequential section list'], collection_type_gid: sequential_section_list_collection_type.gid, depositor: depositor.ms_id) }

      let(:collections) { [team, project, media_list, sequential_section_list] }

      context 'creating a collection' do
        it 'allows admins to create all collection types' do
          expect(admin_ability).to be_able_to(:create, Collection)
          expect(admin_ability).to be_able_to(:create, MediaList)
          expect(admin_ability).to be_able_to(:create, SequentialSectionList)
        end
        it 'allows contributors to create all collection types' do
          expect(contributor_ability).to be_able_to(:create, Collection)
          expect(contributor_ability).to be_able_to(:create, MediaList)
          expect(contributor_ability).to be_able_to(:create, SequentialSectionList)
        end
        it 'does not allow registered users to create any collection types' do
          expect(user_ability).not_to be_able_to(:create, Collection)
          expect(user_ability).not_to be_able_to(:create, MediaList)
          expect(user_ability).not_to be_able_to(:create, SequentialSectionList)
        end
        it 'does not allow guest users to create any collection types' do
          expect(guest_ability).not_to be_able_to(:create, Collection)
          expect(guest_ability).not_to be_able_to(:create, MediaList)
          expect(guest_ability).not_to be_able_to(:create, SequentialSectionList)
        end
      end

      context 'collection is public' do
        before do
          collections.each do |c|
            c.visibility = 'open'
            c.save!
          end
        end

        it 'authorizes admins, contributors, registered users, and guests' do
          expect(admin_ability).to be_able_to(:read, team)
          expect(user_ability).to be_able_to(:read, team)
          expect(guest_ability).to be_able_to(:read, team)

          expect(admin_ability).to be_able_to(:read, project)
          expect(user_ability).to be_able_to(:read, project)
          expect(guest_ability).to be_able_to(:read, project)

          expect(admin_ability).to be_able_to(:read, media_list)
          expect(user_ability).to be_able_to(:read, media_list)
          expect(guest_ability).to be_able_to(:read, media_list)

          expect(admin_ability).to be_able_to(:read, sequential_section_list)
          expect(user_ability).to be_able_to(:read, sequential_section_list)
          expect(guest_ability).to be_able_to(:read, sequential_section_list)
        end
      end

      context 'collection is private' do
        before do
          collections.each do |c|
          c.visibility = 'restricted'
          c.save!
          end
        end

        it 'denies registered users, and guests, authorizes admins' do
          expect(admin_ability).to be_able_to(:read, team)
          expect(user_ability).not_to be_able_to(:read, team)
          expect(guest_ability).not_to be_able_to(:read, team)

          expect(admin_ability).to be_able_to(:read, project)
          expect(user_ability).not_to be_able_to(:read, project)
          expect(guest_ability).not_to be_able_to(:read, project)

          expect(admin_ability).to be_able_to(:read, media_list)
          expect(user_ability).not_to be_able_to(:read, media_list)
          expect(guest_ability).not_to be_able_to(:read, media_list)

          expect(admin_ability).to be_able_to(:read, sequential_section_list)
          expect(user_ability).not_to be_able_to(:read, sequential_section_list)
          expect(guest_ability).not_to be_able_to(:read, sequential_section_list)
        end
      end
    end
  end
end
