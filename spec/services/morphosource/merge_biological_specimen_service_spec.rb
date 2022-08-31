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

  let(:processing_event) { 5.times.collect{ ProcessingEvent.create(title: ['processing event']) } }
  let(:media) { 5.times.collect{ Media.create(title: ['media']) } }



  describe 'call' do

    before do
      media.each_with_index do |media, idx|
        processing_event[idx].ordered_members << media
      end

      specimen[0].ordered_members << imaging_event[0]
      imaging_event[0].ordered_members << processing_event[0]
      

      specimen[1].ordered_members << imaging_event[1]
      imaging_event[1].ordered_members << processing_event[1]

      works = [specimen, imaging_event, processing_event, media].flatten
      works.each(&:save)
      works.each(&:reload)

    end

    it 'success' do
      media_list, ie_list = subject.call(specimen[0].id, specimen[1].id)

      expect(media_list).to eq([])
      #expect(ie_list).to eq([])
    end
  end

end













