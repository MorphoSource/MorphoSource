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

  let(:device)                { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }

  let(:imaging_event) do
    [
      ImagingEvent.create(title: ['imaging event 1'], device_id: [device.id.to_s], physical_object_id: [specimen[0].id], ie_modality: ['Photogrammetry']),
      ImagingEvent.create(title: ['imaging event 2'], device_id: [device.id.to_s], physical_object_id: [specimen[1].id], ie_modality: ['Photogrammetry'])
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
      # force a hard commit so every fixture is reliably visible to the Solr
      # queries the service (and this spec's assertions) depend on
      ActiveFedora::SolrService.commit
    end

    it 'merged media to the specimen and return the media list and IE count that has been moved' do
      media_list, ie_list = subject.call
      expect(media_list.sort).to eq(media_set_1.map(&:id).sort)
      expect(ie_list.count).to eq(media_set_1.count)

      ActiveFedora::SolrService.commit
      merged_specimen_media_ids = specimen[0].media.map(&:id).sort
      all_created_media_ids = (media_set_0 + media_set_1).map(&:id).sort
      expect(merged_specimen_media_ids).to eq(all_created_media_ids)

      expect(ActiveFedora::Base.exists?(specimen[1].id)).to be false
    end

    it 'raises and leaves the duplicate specimen intact when reassigning an ImagingEvent fails' do
      allow_any_instance_of(ImagingEvent).to receive(:save).and_return(false)

      expect { subject.call }.to raise_error(/Failed to reassign ImagingEvent/)

      expect(ActiveFedora::Base.exists?(specimen[1].id)).to be true
    end

    it 'does not destroy the duplicate specimen when Solr still shows media referencing it beyond what this merge processed' do
      # media under its own separate ImagingEvent, so reassigning the discovered
      # media's (shared) IE doesn't incidentally reassign this one too
      extra_ie = ImagingEvent.create(title: ['imaging event extra'], device_id: [device.id.to_s], physical_object_id: [specimen[1].id], ie_modality: ['Photogrammetry'])
      extra_processing_event = ProcessingEvent.create(title: ['processing event extra'])
      extra_media = Media.create(title: ['extra media'])
      extra_processing_event.ordered_members << extra_media
      extra_ie.ordered_members << extra_processing_event
      [extra_ie, extra_processing_event, extra_media].each(&:save)
      [extra_ie, extra_processing_event, extra_media].each(&:reload)
      ActiveFedora::SolrService.commit

      # simulate the initial Solr-based discovery missing extra_media -- it truly
      # (and still, per the fresh commit above) belongs to the duplicate specimen
      allow_any_instance_of(BiologicalSpecimen).to receive(:media).and_return(media_set_1)

      media_list, _ie_list = subject.call
      expect(media_list.sort).to eq(media_set_1.map(&:id).sort)
      expect(media_list).not_to include(extra_media.id)

      expect(ActiveFedora::Base.exists?(specimen[1].id)).to be true
    end

    it 'reports destroy_vetoed_by_guard and leaves the specimen intact when destroy is vetoed (e.g. by the has-media guard)' do
      allow_any_instance_of(BiologicalSpecimen).to receive(:destroy).and_return(false)

      _media_list, _ie_list, outcome = subject.call
      expect(outcome).to eq(:destroy_vetoed_by_guard)
      expect(ActiveFedora::Base.exists?(specimen[1].id)).to be true
    end
  end

end
