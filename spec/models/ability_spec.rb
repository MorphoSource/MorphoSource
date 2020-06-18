require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do

  let(:user)        { FactoryBot.build(:registered_user) }
  let(:contributor) { FactoryBot.build(:contributor) }
  let(:admin)       { FactoryBot.build(:admin) }

  let(:user_ability)        { Ability.new(user) }
  let(:contributor_ability) { Ability.new(contributor) }
  let(:admin_ability)       { Ability.new(admin) }

  describe 'Submissions user abilities' do
    let(:submission_actions) { [ :new, :create, :stage_biological_specimen, :stage_biological_specimen_from_idigbio, :stage_cultural_heritage_object, :stage_device, :stage_imaging_event, :stage_organization, :stage_device_organization, :stage_media, :stage_processing_event, :stage_cho, :stage_taxonomy, :new_organization, :new_organization_submit, :new_taxonomy, :new_taxonomy_submit, :new_device_submit, :new_processing_event_submit ] }

    it 'denies registered users, authorizes admins and contributors' do
      submission_actions.each do |action|
        expect(admin_ability).to be_able_to(action, Submission)
        expect(contributor_ability).to be_able_to(action, Submission)
        expect(user_ability).not_to be_able_to(action, Submission)
      end
    end
  end

  describe 'Fedora user abilities' do
    context 'when creating new objects' do

      it 'denies registered users, authorizes admins and contributors' do
        expect(user_ability).not_to be_able_to(:create, ActiveFedora::Base)
        expect(admin_ability).to be_able_to(:create, ActiveFedora::Base)
        expect(contributor_ability).to be_able_to(:create, ActiveFedora::Base)      
      end
    end
  end
end
