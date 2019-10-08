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

    # When updating an embargo or lease, there won't be an env attribute for title
    context 'the user updates the work from the work edit page' do
      before do
        allow(env).to receive(:attributes).and_return({ "title" => ['title'] })
      end
      it 'changes the title attribute' do
        expect { subject.update(env) }.to change{env.attributes['title']}.to([ 'Spiffy Generated Title' ])
      end
    end
  end

  describe '#generated_title' do
    let(:user) { FactoryBot.build(:user) }
    let(:ability) { Ability.new(user) }
    let(:work) { Media.new }
    let(:modality_attr) { [ 'MagneticResonanceImaging', 'NeutrinoImaging' ] }
    let(:modality_labels) { [ 'MRI', 'Neutrino' ] }
    let(:part_attr) { [ 'leg', 'arm' ] }
    let(:work_parents_attributes) { { "0"=>{"id"=>"parentIE", "_destroy"=>"false"} } }
    let(:work_parents_attributes_multiple) { { "0"=>{"id"=>"parentIE", "_destroy"=>"false"}, "1"=>{"id"=>"parentIEmultiple", "_destroy"=>"false"} } }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }

    before do
      ImagingEvent.create(title: ["Test ImagingEvent"], id: "parentIE", ie_modality: [modality_attr.first])
      ImagingEvent.create(title: ["Test ImagingEvent multiple modality"], id: "parentIEmultiple", ie_modality: [modality_attr[1]])
    end

    describe 'one modality' do
      describe 'no part' do
        let(:attrs) { { 'part' => [], 'work_parents_attributes' => [ work_parents_attributes.first ] } }
        let(:expected_title) { "Element Unspecified [#{modality_labels.first}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'one part' do
        let(:attrs) { { 'work_parents_attributes' => [ work_parents_attributes.first ],
                        'part' => [ part_attr.first ] } }
        let(:expected_title) { "#{part_attr.first.titleize} [#{modality_labels.first}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'more than one part' do
        let(:attrs) { { 'work_parents_attributes' => [ work_parents_attributes.first ],
                        'part' => part_attr } }
        let(:expected_title) { "#{part_attr.sort.join(', ').titleize} [#{modality_labels.first}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
    end
    
    describe 'more than one modality' do
      describe 'no part' do
        let(:attrs) { { 'work_parents_attributes' => work_parents_attributes_multiple,
                        'part' => [] } }
        let(:expected_title) { "Element Unspecified [#{modality_labels.sort.join('/')}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'one part' do
        let(:attrs) { { 'work_parents_attributes' => work_parents_attributes_multiple,
                        'part' => [ part_attr.first ] } }
        let(:expected_title) { "#{part_attr.first.titleize} [#{modality_labels.sort.join('/')}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'more than one part' do
        let(:attrs) { { 'work_parents_attributes' => work_parents_attributes_multiple,
                        'part' => part_attr } }
        let(:expected_title) { "#{part_attr.sort.join(', ').titleize} [#{modality_labels.sort.join('/')}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
    end
  end

end
