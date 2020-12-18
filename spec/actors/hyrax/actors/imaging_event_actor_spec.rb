require 'rails_helper'

RSpec.describe Hyrax::Actors::ImagingEventActor do

  subject { described_class.new(next_actor) }

  let!(:device)     { Device.create(title: ['Model'], modality: ['Photogrammetry'], creator: ['Manufacturer'], description: ['Description']) }

  let(:next_actor)  { double(create: true, update: true) }
  let(:work)        { ImagingEvent.new }
  let(:ability)     { Ability.new(User.new(id: 5)) }
  let(:env)         { Hyrax::Actors::Environment.new(work, ability, attrs) }

  # <device manufacturer> <device name> <modality> Imaging Event (<date created>)
  describe 'generated_title' do
    let(:attrs) { { 'title' => ['Title'],
                    'ie_modality' => ['Photogrammetry'],
                    'device_id' => [device.id],
                    'date_created' => ['2020-12-15'] } }
    context 'all attributes are present' do
      let(:title) { "Manufacturer Model Photogrammetry Imaging Event (2020-12-15)" }

      it { expect(subject.generated_title(env)).to eq(title) }
    end

    context 'no device present' do
      let(:title) { "Photogrammetry Imaging Event (2020-12-15)" }

      before do
        attrs['device_id'] = []
      end

      it { expect(subject.generated_title(env)).to eq(title) }
    end

    context 'no date created or modality' do
      let(:title) { "Manufacturer Model Imaging Event (No Event Date)" }

      before do
        attrs['date_created'] = []
        attrs['ie_modality'] = []
      end

      it { expect(subject.generated_title(env)).to eq(title) }
    end
  end
end
