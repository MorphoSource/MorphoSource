require 'rails_helper'

RSpec.describe Submission, type: :model do

  describe 'steps' do
    specify { expect(subject.steps).to eq([ described_class::STEP_INSTITUTION, described_class::STEP_OBJECT,
                                            described_class::STEP_IMAGING_EVENT ]) }

    describe '#current_step' do
      describe 'current_step variable is nil' do
        before { subject.current_step = nil }
        it 'returns the first step' do
          expect(subject.current_step).to eq(subject.steps.first)
        end
      end
      describe 'current_step variable is set' do
        let(:step) { described_class::STEP_OBJECT }
        before { subject.current_step = step }
        it 'returns the set step' do
          expect(subject.current_step).to eq(step)
        end
      end
    end

    describe '#first_step?' do
      describe 'current step is first step' do
        before { subject.current_step = subject.steps.first }
        specify { expect(subject.first_step?).to be true }
      end
      describe 'current step is not first step' do
        specify do
          subject.steps[1..-1].each do |step|
            subject.current_step = step
            expect(subject.first_step?).to be false
          end
        end
      end
    end

    describe '#last_step?' do
      describe 'current step is last step' do
        before { subject.current_step = subject.steps.last }
        specify { expect(subject.last_step?).to be true }
      end
      describe 'current step is not last step' do
        let(:next_to_last_index) { subject.steps.size - 2 }
        specify do
          subject.steps[0..next_to_last_index].each do |step|
            subject.current_step = step
            expect(subject.last_step?).to be false
          end
        end
      end
    end

    describe '#next_step' do
      describe 'current step is not last step' do
        let(:next_to_last_index) { subject.steps.size - 2 }
        it 'increments the step index' do
          subject.steps[0..next_to_last_index].each do |step|
            subject.current_step = step
            prev_idx = subject.steps.index(subject.current_step)
            subject.next_step
            expect(subject.steps.index(subject.current_step)).to eq(prev_idx + 1)
          end
        end
      end
      describe 'current step is last step' do
        before { subject.current_step = subject.steps.last }
        it 'resets current step to first step' do
          expect {subject.next_step}.to change{subject.current_step}.to(subject.steps.first)
        end
      end
    end

    describe '#previous_step' do
      describe 'current step is not first step' do
        it 'decrements the step index' do
          subject.steps[1..-1].each do |step|
            subject.current_step = step
            prev_idx = subject.steps.index(subject.current_step)
            subject.previous_step
            expect(subject.steps.index(subject.current_step)).to eq(prev_idx - 1)
          end
        end
      end
      describe 'current step is first step' do
        before { subject.current_step = subject.steps.first }
        it 'leaves the current step unchanged' do
          expect {subject.previous_step}.to_not change{subject.current_step}
        end
      end
    end

  end

end
