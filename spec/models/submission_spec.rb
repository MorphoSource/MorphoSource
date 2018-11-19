require 'rails_helper'

RSpec.describe Submission, type: :model do

  let(:non_first_steps) { described_class::STEPS - [ described_class.first_step ] }
  let(:last_steps) { described_class::STEPS.select { | step| step.next_step.nil? } }
  let(:non_last_steps) { described_class::STEPS - last_steps }

  describe '.first_step' do
    it 'identifies the first step' do
      expect(described_class.first_step).to eq(described_class::STEP_INSTITUTION)
    end
  end

  describe '.step' do
    it 'returns the step with provided name' do
      described_class::STEPS.each do |step|
        expect(described_class.step(step.name)).to eq(step)
      end
    end
  end

  describe '#all_valid?' do
    before do
      allow(subject).to receive(:valid?) { true }
    end
    describe 'all steps are valid' do
      it 'returns true' do
        expect(subject.all_valid?).to be true
      end
    end
    describe 'a step is not valid' do
      before do
        subject.current_step = Submission::STEP_OBJECT
        allow(subject).to receive(:valid?) { false }
      end
      it 'returns false' do
        expect(subject.all_valid?).to be false
      end
    end
  end

  describe '#current_step' do
    describe 'current_step variable is nil' do
      before { subject.current_step = nil }
      it 'returns the first step' do
        expect(subject.current_step).to eq(described_class.first_step)
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
      before { subject.current_step = described_class.first_step }
      specify { expect(subject.first_step?).to be true }
    end
    describe 'current step is not first step' do
      specify do
        non_first_steps.each do |step|
          subject.current_step = step
          expect(subject.first_step?).to be false
        end
      end
    end
  end

  describe '#last_step?' do
    describe 'current step is last step' do
      specify do
        last_steps.each do |step|
          subject.current_step = step
          expect(subject.last_step?).to be true
        end
      end
    end
    describe 'current step is not last step' do
      specify do
        non_last_steps.each do |step|
          subject.current_step = step
          expect(subject.last_step?).to be false
        end
      end
    end
  end

  describe '#step_forward' do
    describe 'current step is not last step' do
      it 'changes the current step to its next step' do
        non_last_steps.each do |step|
          subject.current_step = step
          nxt_stp = step.next_step
          subject.step_forward
          expect(subject.current_step).to eq(nxt_stp)
        end
      end
    end
    describe 'current step is last step' do
      it 'resets current step to first step' do
        last_steps.each do |step|
          subject.current_step = step
          subject.step_forward
          expect(subject.current_step).to eq(described_class.first_step)
        end
      end
    end
  end

  describe '#step_back' do
    describe 'current step is not first step' do
      it 'changes the current step to its previous step' do
        non_first_steps.each do |step|
          subject.current_step = step
          prv_stp = step.previous_step
          subject.step_back
          expect(subject.current_step).to eq(prv_stp)
        end
      end
    end
    describe 'current step is first step' do
      before { subject.current_step = described_class.first_step }
      it 'leaves the current step unchanged' do
        expect {subject.step_back}.to_not change{subject.current_step}
      end
    end
  end

end
