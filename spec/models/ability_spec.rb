require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do

  let!(:user) { FactoryBot.build(:user) }

  subject { Ability.new(user) }

  describe 'create submissions' do

    describe 'logged in' do
      before { allow(user).to receive(:groups) { [ 'registered' ] } }
      it { is_expected.to be_able_to(:create, Submission) }
    end

    describe 'not logged in' do
      it { is_expected.to_not be_able_to(:create, Submission) }
    end

  end

end
