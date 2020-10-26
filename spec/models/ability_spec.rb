require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do

  let(:user)        { FactoryBot.build(:registered_user) }
  let(:contributor) { FactoryBot.build(:contributor) }
  let(:admin)       { FactoryBot.build(:admin) }
  let(:guest)       { FactoryBot.build(:user, :guest) }

  let(:user_ability)        { Ability.new(user) }
  let(:contributor_ability) { Ability.new(contributor) }
  let(:admin_ability)       { Ability.new(admin) }
  let(:guest_ability)       { Ability.new(guest) }

  describe 'Submissions user abilities' do
    let(:submission_actions) { [ :new, :create, :stage_biological_specimen, :stage_biological_specimen_from_idigbio, :stage_cultural_heritage_object, :stage_device, :stage_imaging_event, :stage_organization, :stage_device_organization, :stage_media, :stage_processing_event, :stage_cho, :stage_taxonomy, :new_organization, :new_organization_submit, :new_taxonomy, :new_taxonomy_submit, :new_device_submit, :new_processing_event_submit ] }

    it 'denies registered users and guests, authorizes admins and contributors' do
      submission_actions.each do |action|
        expect(admin_ability).to be_able_to(action, Submission)
        expect(contributor_ability).to be_able_to(action, Submission)
        expect(user_ability).not_to be_able_to(action, Submission)
        expect(guest_ability).not_to be_able_to(action, Submission)
      end
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
end
