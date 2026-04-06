# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Actors::ProcessingEventActor do
  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }

  let(:user)    { FactoryBot.build(:user) }
  let(:ability) { Ability.new(user) }
  let(:work)    { ProcessingEvent.new }

  describe '#create' do
    let(:env) { Hyrax::Actors::Environment.new(work, ability, { 'date_created' => ['2024-01-15'] }) }

    before do
      allow(subject).to receive(:generated_title).and_return('Generated Title')
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end

    it 'sets the title attribute via generated_title' do
      expect { subject.create(env) }.to change { env.attributes['title'] }.to(['Generated Title'])
    end
  end

  describe '#update' do
    let(:env) { Hyrax::Actors::Environment.new(work, ability, { 'date_created' => ['2024-01-15'] }) }

    before do
      allow(subject).to receive(:generated_title).and_return('Updated Title')
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end

    it 'sets the title attribute via generated_title' do
      expect { subject.update(env) }.to change { env.attributes['title'] }.to(['Updated Title'])
    end
  end

  describe '#generated_title' do
    let(:date_created) { '2024-01-15' }

    context 'with no parents and no date' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, {}) }

      it 'uses "No Event Date" as the date' do
        expect(subject.generated_title(env)).to eq('Processing Event (No Event Date)')
      end
    end

    context 'with no parents and a date' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, { 'date_created' => [date_created] }) }

      it 'returns a title with just the date' do
        expect(subject.generated_title(env)).to eq("Processing Event (#{date_created})")
      end
    end

    context 'with an ImagingEvent (AF) parent' do
      let(:device)        { Device.create(title: ['device'], modality: ['Photogrammetry']) }
      let(:imaging_event) { ImagingEvent.create(title: ['ie'], device_id: [device.id], ie_modality: device.modality) }
      let(:env) do
        Hyrax::Actors::Environment.new(work, ability, {
          'date_created' => [date_created],
          'work_parents_attributes' => { '0' => { 'id' => imaging_event.id, '_destroy' => 'false' } }
        })
      end

      it 'prefixes the title with IE<id>' do
        expect(subject.generated_title(env)).to eq("IE#{imaging_event.id} Processing Event (#{date_created})")
      end
    end

    context 'with an ImagingEventResource (Valkyrie) parent' do
      let(:imaging_event) { Hyrax.persister.save(resource: ImagingEventResource.new(title: ['test ie'])) }
      let(:env) do
        Hyrax::Actors::Environment.new(work, ability, {
          'date_created' => [date_created],
          'work_parents_attributes' => { '0' => { 'id' => imaging_event.id.to_s, '_destroy' => 'false' } }
        })
      end

      it 'prefixes the title with IE<id>' do
        expect(subject.generated_title(env)).to eq("IE#{imaging_event.id} Processing Event (#{date_created})")
      end
    end

    context 'with a Media (AF) parent' do
      let(:media) { FactoryBot.create(:media) }
      let(:env) do
        Hyrax::Actors::Environment.new(work, ability, {
          'date_created' => [date_created],
          'work_parents_attributes' => { '0' => { 'id' => media.id, '_destroy' => 'false' } }
        })
      end

      it 'prefixes the title with M<id>' do
        expect(subject.generated_title(env)).to eq("M#{media.id} Processing Event (#{date_created})")
      end
    end
  end
end
