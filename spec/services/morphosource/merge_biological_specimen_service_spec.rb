require 'rails_helper'

RSpec.describe Morphosource::MergeBiologicalSpecimenService do

  let!(:specimen) do
    [
        BiologicalSpecimen.create(title: [ 'abc:123' ],
                                  catalog_number: [ '123' ],
                                  institution_code: [ 'INST1' ],
                                  collection_code: [ 'abc' ],
                                  vouchered: [ "Yes" ]),
        BiologicalSpecimen.create(title: [ 'abc:456' ],
                                  catalog_number: [ '456' ],
                                  institution_code: [ 'INST2' ],
                                  collection_code: [ 'abc' ],
                                  vouchered: [ "Yes" ]),
    ]
  end

  let(:device)                { Device.create(title: ['device'], modality: ['Photogrammetry']) }

  let(:imaging_event) do 
    [
      ImagingEvent.create(title: ['imaging event 1'], device_id: [device.id], physical_object_id: [specimen[0].id], ie_modality: ['Photogrammetry']),
      ImagingEvent.create(title: ['imaging event 2'], device_id: [device.id], physical_object_id: [specimen[1].id], ie_modality: ['Photogrammetry'])
    ]
  end

  let(:processing_event_set_0) { 2.times.collect{ ProcessingEvent.create(title: ['processing event']) } }
  let(:media_set_0) { 2.times.collect{ Media.create(title: ['media']) } }

  let(:processing_event_set_1) { 3.times.collect{ ProcessingEvent.create(title: ['processing event']) } }
  let(:media_set_1) { 3.times.collect{ Media.create(title: ['media']) } }

  describe 'call' do

    subject { described_class.new(specimen[0].id, specimen[1].id, true, false) }

    before do
      media_set_0.each_with_index do |media, idx|
        processing_event_set_0[idx].ordered_members << media
      end
      media_set_1.each_with_index do |media, idx|
        processing_event_set_1[idx].ordered_members << media
      end

      specimen[0].ordered_members << imaging_event[0]
      imaging_event[0].ordered_members += processing_event_set_0
      specimen[1].ordered_members << imaging_event[1]
      imaging_event[1].ordered_members += processing_event_set_1

      works = [specimen, imaging_event, processing_event_set_0, processing_event_set_1, media_set_0, media_set_1].flatten
      works.each(&:save)
      works.each(&:reload)
    end

    it 'merged media to the specimen and return the media list and IE count that has been moved' do
      media_list, ie_list = subject.call
      expect(media_list.sort).to eq(media_set_1.map(&:id).sort)
      expect(ie_list.count).to eq(media_set_1.count)

      merged_specimen_media_ids = specimen[0].media.map(&:id).sort
      all_created_media_ids = (media_set_0 + media_set_1).map(&:id).sort
      expect(merged_specimen_media_ids).to eq(all_created_media_ids)
    end
  end

end
