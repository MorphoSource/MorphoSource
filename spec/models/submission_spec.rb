require 'rails_helper'

RSpec.describe Submission, type: :model do

  describe 'steps' do
    specify { expect(subject.steps).to eq([ described_class::STEP_INSTITUTION ]) }
    specify { expect(subject.current_step).to eq(described_class::STEP_INSTITUTION) }

    describe '#first_step?' do
      describe 'current step is first step' do
        before { subject.current_step = described_class::STEP_INSTITUTION }
        specify { expect(subject.first_step?).to be true }
      end
      describe 'current step is not first step' do
        before { subject.current_step = 'object' }
        specify { expect(subject.first_step?).to be false }
      end
    end

    describe '#last_step?' do
      describe 'current step is last step' do
        before { subject.current_step = described_class::STEP_INSTITUTION }
        specify { expect(subject.last_step?).to be true }
      end
      describe 'current step is not last step' do
        before { subject.current_step = 'object' }
        specify { expect(subject.last_step?).to be false }
      end
    end

    describe '#next_step' do
      pending 'inclusion of more than one step'
    end

    describe '#next_step' do
      pending 'inclusion of more than one step'
    end

  end

end
