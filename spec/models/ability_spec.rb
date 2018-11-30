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
    describe 'create_biological_specimen' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:create_biological_specimen, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:create_biological_specimen, Submission) }
      end
    end
    describe 'create_cultural_heritage_object' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:create_cultural_heritage_object, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:create_cultural_heritage_object, Submission) }
      end
    end
    describe 'create_institution' do
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:create_institution, Submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:create_institution, Submission) }
      end
    end
  end

end
