# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::Actors::MediaActor do

  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }

  describe '#create' do
    let(:work) { Media.new }
    let(:ability) { Ability.new(User.new) }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do
      allow(subject).to receive(:generated_title) { 'Spiffy Generated Title' }
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end
    it 'changes the title attribute' do
      expect { subject.create(env) }.to change{env.attributes['title']}.to([ 'Spiffy Generated Title' ])
    end
  end

  describe '#update' do
    let(:work) { Media.new(title: [ 'Previous title' ]) }
    let(:ability) { Ability.new(User.new) }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do
      allow(subject).to receive(:generated_title) { 'Spiffy Generated Title' }
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end
    it 'changes the title attribute' do
      expect { subject.update(env) }.to change{env.attributes['title']}.to([ 'Spiffy Generated Title' ])
    end
  end

  describe '#generated_title' do
    let(:user) { FactoryBot.build(:user) }
    let(:ability) { Ability.new(user) }
    let(:work) { Media.new }
    let(:modality_attr) { [ 'MagneticResonanceImaging', 'NeutrinoImaging' ] }
    let(:modality_labels) { [ 'Magnetic Resonance Imaging (MRI)', 'Neutrino Imaging' ] }
    let(:part_attr) { [ 'leg', 'arm' ] }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    describe 'one modality' do
      describe 'no part' do
        let(:attrs) { { 'modality' => [ modality_attr.first ],
                        'part' => [] } }
        let(:expected_title) { "[#{modality_labels.first}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'one part' do
        let(:attrs) { { 'modality' => [ modality_attr.first ],
                        'part' => [ part_attr.first ] } }
        let(:expected_title) { "#{part_attr.first.titleize} [#{modality_labels.first}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'more than one part' do
        let(:attrs) { { 'modality' => [ modality_attr.first ],
                        'part' => part_attr } }
        let(:expected_title) { "#{part_attr.sort.join(', ').titleize} [#{modality_labels.first}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
    end
    describe 'more than one modality' do
      describe 'no part' do
        let(:attrs) { { 'modality' => modality_attr,
                        'part' => [] } }
        let(:expected_title) { "[#{modality_labels.sort.join(', ')}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'one part' do
        let(:attrs) { { 'modality' => modality_attr,
                        'part' => [ part_attr.first ] } }
        let(:expected_title) { "#{part_attr.first.titleize} [#{modality_labels.sort.join(', ')}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'more than one part' do
        let(:attrs) { { 'modality' => modality_attr,
                        'part' => part_attr } }
        let(:expected_title) { "#{part_attr.sort.join(', ').titleize} [#{modality_labels.sort.join(', ')}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
    end
  end

end
