require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  let!(:imaging_event)      { ImagingEvent.create(title: ['imaging event'], ie_modality: ["MagneticResonanceImaging"]) }
  let!(:media1)             { Media.create(title: ['media1']) }
  let!(:media2)             { Media.create(title: ['media2']) }
  let!(:media3)             { Media.create(title: ['media3']) }
  let!(:processing_event1)  { ProcessingEvent.create(title: ['processing event 1']) }
  let!(:processing_event2)  { ProcessingEvent.create(title: ['processing event 2']) }
  let(:specimen)            { BiologicalSpecimen.create(title: ['title'], vouchered: ['Yes']) }
  let(:cho)                 { CulturalHeritageObject.create(title: ['title'], vouchered: ['Yes']) }
  let(:works)               { [imaging_event, media1, media2, media3, processing_event1, processing_event2] }
  let(:child_media)         { [media1, media2, media3] }

  let(:media1_doc)          { SolrDocument.find(media1.id) }
  let(:media2_doc)          { SolrDocument.find(media2.id) }
  let(:media3_doc)          { SolrDocument.find(media3.id) }
  let(:media_docs)          { [media1_doc, media2_doc, media3_doc] }

  let(:updated_media1_doc)  { SolrDocument.find(media1.id)}
  let(:updated_media2_doc)  { SolrDocument.find(media2.id) }
  let(:updated_media3_doc)  { SolrDocument.find(media3.id) }
  let(:updated_docs)        { [updated_media1_doc, updated_media2_doc, updated_media3_doc] }

  before do
    imaging_event.members << media1
    media1.members << processing_event1
    processing_event1.members << media2
    media2.members << processing_event2
    processing_event2.members << media3
    works.each(&:save)
    works.each(&:update_index)
  end

  describe 'modality facet' do
    context 'imaging event modality is updated' do
      let(:updated_media1_doc)  { SolrDocument.find(media1.id)}
      let(:updated_media2_doc)  { SolrDocument.find(media2.id) }
      let(:updated_media3_doc)  { SolrDocument.find(media3.id) }
      let(:updated_docs)        { [updated_media1_doc, updated_media2_doc, updated_media3_doc] }

      context 'modality is changed' do
        it 'updates child media doc modalities' do
          expect(media_docs.map{ |d| d["media_modality_tesim"] }.uniq).to match_array([["Magnetic Resonance Imaging (MRI)"]])

          imaging_event.ie_modality = ["PositronEmissionTomography"]
          imaging_event.save

          expect(updated_docs.map{ |d| d["media_modality_tesim"] }.uniq).to match_array([["Positron Emission Tomography (PET)"]])
        end
      end
    end
  end

  describe 'physical object type' do
    let(:imaging_event2)  { ImagingEvent.create(title: ['imaging event 2']) }

    before do
      specimen.members << imaging_event
      specimen.save
      works.each(&:update_index)
    end

    context 'imaging event associated with a different physical object' do

      it 'updates child media object type' do
        expect(media_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Biological Specimen"]])

        specimen.members -= [imaging_event]
        cho.members << imaging_event
        [specimen, cho].each(&:save)

        expect(updated_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Cultural Heritage Object"]])
      end
    end

    context 'media associated with a different imaging event' do
      let(:imaging_event2)  { ImagingEvent.create(title: ['imaging event 2']) }

      before do
        cho.members << imaging_event2
        cho.save
      end

      it 'updates child media object type' do
        expect(media_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Biological Specimen"]])

        imaging_event.members -= [media1]
        imaging_event2.members << media1
        [imaging_event, imaging_event2].each(&:save)

        expect(updated_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Cultural Heritage Object"]])
      end
    end

    context 'media associated with a different parent media' do
      let(:media4)                { Media.create(title: ['media 4']) }
      let(:media4_doc)            { SolrDocument.find(media4.id) }
      let(:processing_event3)     { ProcessingEvent.create(title: ['processing event 2']) }
      let(:updated_media2_doc)    { SolrDocument.find(media2.id) }
      let(:updated_media3_doc)    { SolrDocument.find(media3.id) }
      let(:updated_docs)          { [updated_media2_doc, updated_media3_doc, media4_doc] }

      before do
        cho.members << imaging_event2
        imaging_event2.members << media4
        media4.members << processing_event3
        [cho, imaging_event2, media4].each(&:save)
      end

      it 'updates child media object type' do
        expect(media_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Biological Specimen"]])

        processing_event1.members -= [media2]
        processing_event3.members << media2
        [processing_event1, processing_event3].each(&:save)

        expect(updated_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Cultural Heritage Object"]])
      end
    end

    context 'media associated with a different imaging event' do

      before do
        cho.members << imaging_event2
        cho.save
      end

      it 'updates child media object type' do
        expect(media_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Biological Specimen"]])

        imaging_event.members -= [media1]
        imaging_event2.members << media1
        [imaging_event, imaging_event2].each(&:save)

        expect(updated_docs.map{ |d| d["media_physical_object_type_tesim"] }.uniq).to match_array([["Cultural Heritage Object"]])
      end
    end
  end

  describe 'organization' do
    let(:organization1) { Organization.create(title: ['organization 1']) }

    before do
      organization1.members << specimen
      specimen.members << imaging_event
      [organization1, specimen].each(&:save)
    end

    context 'object is associated with a different organization' do
      let(:organization2) { Organization.create(title: ['organization 2']) }

      it 'updates the media records' do
        expect(media_docs.map{ |d| d["media_organization_tesim"] }.uniq).to match_array([["organization 1"]])

        organization1.members -= [specimen]
        organization2.members << specimen
        [organization1, organization2].each(&:save)

        expect(updated_docs.map{ |d| d["media_organization_tesim"] }.uniq).to match_array([["organization 2"]])
      end
    end

    context 'organization name is changed' do

      it 'updates the media records' do
        expect(media_docs.map{ |d| d["media_organization_tesim"] }.uniq).to match_array([["organization 1"]])

        organization1.title = ['new title']
        organization1.save

        expect(updated_docs.map{ |d| d["media_organization_tesim"] }.uniq).to match_array([["new title"]])
      end
    end
  end
end
