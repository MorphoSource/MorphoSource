require 'rails_helper'

RSpec.describe MediaIndexer do
  #- Specimen1 
  #  
  #  - IE1 
  #    
  #    - PE1 
  #      - Media1 
  #    
  #    - PE2 
  #      - Media2 
  let(:specimen)                { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes']) }
  let(:media1)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
  let(:media2)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
  let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let(:imaging_event)           { ImagingEvent.create(title: ['title'], device_id: [device.id], ie_modality: device.modality) }
  let!(:processing_event1)       { ProcessingEvent.create(title: ['processing_event']) }
  let!(:processing_event2)       { ProcessingEvent.create(title: ['processing_event']) }
  let!(:works)                  { [ specimen, device, imaging_event, processing_event1, processing_event2 ] }

  subject(:solr_document)       { described_class.new(media1).generate_solr_document }

  before do
    specimen.ordered_members << imaging_event
    imaging_event.ordered_members << processing_event1
    imaging_event.ordered_members << processing_event2
    processing_event1.ordered_members << media1
    processing_event2.ordered_members << media2
    works.each(&:save)
    works.each(&:reload)
  end

  describe 'custom fields' do
    it 'indexes related_media_ids' do
      expect(subject['related_media_ids_ssim']).to include(media1.id, media2.id)
    end
  end

end
