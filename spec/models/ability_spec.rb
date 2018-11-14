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
    describe 'show' do
      let(:submission) { Submission.new }
      describe 'logged in' do
        before { allow(user).to receive(:groups) { [ 'registered' ] } }
        it { is_expected.to be_able_to(:show, submission) }
      end
      describe 'not logged in' do
        it { is_expected.to_not be_able_to(:show, submission) }
      end
    end
  end

end
