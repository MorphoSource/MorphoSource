require 'rails_helper'

RSpec.describe Morphosource::DataCuration::RelationshipRepairService do

  include TestHelpers

  let!(:device)   { FactoryBot.create(:device, id: '000200000') }
  let!(:specimen) { FactoryBot.create(:biological_specimen, id: '000200001') }
  let(:params)    { { } }

  subject { described_class.call(params) }

  before do
    allow(BiologicalSpecimen).to receive(:find).with(specimen.id).and_return(specimen)
  end

  describe 'call' do

    it 'instantiates the service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      subject
    end

    context 'raw media' do
      let!(:imaging_event)  { FactoryBot.create(:imaging_event, id: '000200002', physical_object_id: [specimen.id], device_id: [device.id]) }
      let!(:media)          { FactoryBot.create(:media, id: '000200003') }
      let(:params)          { { media_id: media.id } }

      before do
        allow(ImagingEvent).to receive(:find).with(imaging_event.id).and_return(imaging_event)
      end

      it 'repairs the Fedora relationships' do
        expect(media.physical_objects).to eq([])
        output = capture_stdout { subject }
        expect(output).to include("Relationships repaired for #{media.id}")
        expect(output).to include('RelationshipRepairService media update complete.')
        expect(output).to include("0 media on MorphoSource with broken associations: []")
        expect(media.physical_objects).to match_array([specimen])
      end

      context 'imaging event has ordered members' do
        let!(:processing_event)  { FactoryBot.create(:processing_event, id: '000200010') }

        before do
          imaging_event.ordered_members << processing_event
          imaging_event.save
        end

        it 'does not repair relationships' do
          expect(media.physical_objects).to eq([])
          output = capture_stdout { subject }
          expect(media.physical_objects).to eq([])
          expect(output).to include("Media: #{media.id} not able to be repaired.")
          expect(output).to include("1 media on MorphoSource with broken associations:", media.id)
        end
      end
    end

    context 'derived media' do
      let!(:imaging_event)    { FactoryBot.create(:imaging_event, id: '000200002', physical_object_id: [specimen.id], device_id: [device.id]) }
      let!(:processing_event) { FactoryBot.create(:processing_event, id: '000200003') }
      let!(:media)            { FactoryBot.create(:media, id: '000200004') }
      let(:params)            { { media_id: media.id } }

      before do
        allow(Media).to receive(:find).with(media.id).and_return(media)
        allow(ProcessingEvent).to receive(:find).with(processing_event.id).and_return(processing_event)
        allow(ImagingEvent).to receive(:find).with(imaging_event.id).and_return(imaging_event)
      end

      it 'repairs the Fedora relationships' do
        expect(media.physical_objects).to eq([])
        output = capture_stdout { subject }
        expect(output).to include("Relationships repaired for #{media.id}")
        expect(media.physical_objects).to match_array([specimen])
      end
    end

    context 'missing imaging event' do
      let!(:processing_event) { FactoryBot.create(:processing_event, id: '000200002') }
      let!(:media)            { FactoryBot.create(:media, id: '000200003') }
      let(:params)            { { media_id: media.id } }

      before do
        allow(Media).to receive(:find).with(media.id).and_return(media)
        allow(ProcessingEvent).to receive(:find).with(processing_event.id).and_return(processing_event)
      end

      it 'does not repair relationships' do
        expect(media.physical_objects).to eq([])
        output = capture_stdout { subject }
        expect(media.physical_objects).to eq([])
        expect(output).to include("Media: #{media.id} not able to be repaired.")
        expect(output).to include("1 media on MorphoSource with broken associations:", media.id)
      end
    end

    context 'unexpected works in works_list' do
      let!(:imaging_event)            { FactoryBot.create(:imaging_event, id: '000200002', physical_object_id: [specimen.id], device_id: [device.id]) }
      let!(:cultural_heritage_object) { FactoryBot.create(:cultural_heritage_object, id: '000200003') }
      let!(:device2)                  { FactoryBot.create(:device, id: '000200004')}
      let!(:media)                    { FactoryBot.create(:media, id: '000200005') }
      let(:params)                    { { media_id: media.id } }

      before do
        allow(ImagingEvent).to receive(:find).with(imaging_event.id).and_return(imaging_event)
        allow(CulturalHeritageObject).to receive(:find).with(cultural_heritage_object.id).and_return(cultural_heritage_object)
        allow(Device).to receive(:find).with(device2.id).and_return(device2)
        allow(Media).to receive(:find).with(media.id).and_return(media)
      end

      it 'does not repair relationships' do
        expect(media.physical_objects).to eq([])
        output = capture_stdout { subject }
        expect(media.physical_objects).to eq([])
        expect(output).to include("Media: #{media.id} not able to be repaired.")
        expect(output).to include("1 media on MorphoSource with broken associations:", media.id)
      end
    end

    context 'processing event has ordered members' do
      let!(:imaging_event)    { FactoryBot.create(:imaging_event, id: '000200002', physical_object_id: [specimen.id], device_id: [device.id]) }
      let!(:processing_event) { FactoryBot.create(:processing_event, id: '000200003') }
      let!(:media)            { FactoryBot.create(:media, id: '000200004') }
      let!(:another_media)    { FactoryBot.create(:media, id: '000200005')}
      let(:params)            { { media_id: media.id } }

      before do
        allow(Media).to receive(:find).with(media.id).and_return(media)
        allow(ProcessingEvent).to receive(:find).with(processing_event.id).and_return(processing_event)
        allow(ImagingEvent).to receive(:find).with(imaging_event.id).and_return(imaging_event)
        processing_event.ordered_members << another_media
        processing_event.save
      end

      it 'does not repair the relationships' do
        expect(media.physical_objects).to eq([])
        output = capture_stdout { subject }
        expect(media.physical_objects).to eq([])
        expect(output).to include("Media: #{media.id} not able to be repaired.")
        expect(output).to include("2 media on MorphoSource with broken associations:", media.id, another_media.id)
      end
    end

    context 'LDP gone' do
      let!(:imaging_event)    { FactoryBot.create(:imaging_event, id: '000200002', physical_object_id: [specimen.id], device_id: [device.id]) }
      let!(:processing_event) { FactoryBot.create(:processing_event, id: '000200003') }
      let!(:media)            { FactoryBot.create(:media, id: '000200004') }
      let(:params)            { { media_id: media.id } }

      before do
        allow(Media).to receive(:find).with(media.id).and_return(media)
        allow(ProcessingEvent).to receive(:find).with(processing_event.id).and_return(processing_event)
        imaging_event.destroy!
        allow(ActiveFedora::Base).to receive(:find).and_call_original
        allow(ActiveFedora::Base).to receive(:find).with(imaging_event.id).and_raise(Ldp::Gone)
      end

      it 'does not repair the relationships' do
        expect(media.physical_objects).to eq([])
        output = capture_stdout { subject }
        expect(media.physical_objects).to eq([])
        expect(output).to include("One or more required parameters is not present or incorrect")
        expect(output).to include("Media: #{media.id} not able to be repaired.")
        expect(output).to include("1 media on MorphoSource with broken associations:", media.id)
      end
    end
  end
end
