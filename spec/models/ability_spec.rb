require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do

  let!(:user) { FactoryBot.build(:user) }

  subject { Ability.new(user) }

  describe 'submissions' do
    describe 'create' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:create, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:create, Submission) }
      end
    end
    describe 'stage_biological_specimen' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:stage_biological_specimen, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:stage_biological_specimen, Submission) }
      end
    end
    describe 'stage_cultural_heritage_object' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:stage_cultural_heritage_object, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:stage_cultural_heritage_object, Submission) }
      end
    end
    describe 'stage_device' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:stage_device, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:stage_device, Submission) }
      end
    end
    describe 'stage_imaging_event' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:stage_imaging_event, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:stage_imaging_event, Submission) }
      end
    end
    describe 'stage_institution' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:stage_institution, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:stage_institution, Submission) }
      end
    end
    describe 'stage_media' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:stage_media, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:stage_media, Submission) }
      end
    end
  end

end
