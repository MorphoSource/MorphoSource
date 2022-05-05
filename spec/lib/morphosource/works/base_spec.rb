# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Works::Base do
  let(:organization)    { Organization.create(title: ['organization title']) }
  let(:specimen1)       { BiologicalSpecimen.create(title: ['title'], vouchered: ["Yes"], organization_id: [organization.id], sex: ['female ']) }
  let(:specimen2)       { BiologicalSpecimen.create(title: ['title'], vouchered: ["No"], organization_id: [organization.id]) }
  let(:media1)          { Media.create(title: ['title'], side:[' left'], media_type:['ctimageseries '], unit:[' cm ']) }
  let(:media2)          { Media.create(title: ['title']) }
  let(:media3)          { Media.create(title: ['title']) }
  let(:file_set1)       { FileSet.create }
  let(:file_set2)       { FileSet.create }
  let(:file_set3)       { FileSet.create }
  let(:device)          { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let(:imagingEvent)    { ImagingEvent.create(title: ['title'], device_id: [device.id], physical_object_id: [specimen1.id], ie_modality: device.modality, pixel_spacing_calibration:[' fiducial'], target_type: ['Reflection ']) }
  let(:imagingEvent2)   { ImagingEvent.create(title: ['title'], device_id: [device.id], physical_object_id: [specimen2.id], ie_modality: device.modality) }
  let(:processingEvent) { ProcessingEvent.create(title: ['title']) }
  let(:works)           { [media1, media2, media3, imagingEvent, imagingEvent2, processingEvent, file_set1, file_set2, file_set3] }
  let(:works2)           { [media1, specimen1, imagingEvent] }

  describe '#descendants' do
    let(:media1_desc)    { [file_set1, processingEvent, media2, file_set2] }
    let(:media3_desc)    { [file_set3] }

    before do
      imagingEvent.ordered_members << media1
      media1.ordered_members << processingEvent << file_set1
      processingEvent.ordered_members << media2
      media2.ordered_members << file_set2
      imagingEvent2.ordered_members << media3
      media3.ordered_members << file_set3
      works.each(&:save)
    end

    it 'finds all children (works and filesets) of a work' do
      expect(media1.descendants).to match_array(media1_desc)
      expect(media3.descendants).to match_array(media3_desc)
    end
  end

  describe 'user_with_ownership' do
    subject         { media1.user_with_ownership }
    let(:owner)     { User.create(email: 'owner@email.com', password: 'password') }
    let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
    before do
      media1.depositor = depositor.ms_id
    end
    context 'work has an owner' do
      before do
        media1.owner = owner.ms_id
      end
      it 'returns the owner' do
        expect(subject).to eq(owner.ms_id)
      end
    end
    context 'work does not have an owner' do
      context 'ms_id does not exist' do
        before do
          media1.owner = 'notanmsid'
        end
        it 'returns the depositor' do
          expect(subject).to eq(depositor.ms_id)
        end
      end
      context 'ms_id is nil' do
        before do
          media1.owner = nil
        end
        it 'returns the depositor' do
          expect(subject).to eq(depositor.ms_id)
        end
      end
      context 'ms_id is empty' do
        before do
          media1.owner = ''
        end
        it 'returns the depositor' do
          expect(subject).to eq(depositor.ms_id)
        end
      end
    end
  end

  describe 'member_of_public_collection_ids' do
    let(:user)  { User.new(ms_id: 'abcdef') }
    let(:work)  { Media.create(title: ['media title']) }
    let(:collection_type) { Hyrax::CollectionType.create(title: 'Project') }
    let(:public_collection_1) { Collection.create(title: ['Public Collection 1'], collection_type_gid: collection_type.gid, depositor: user.ms_id, visibility: 'open') }
    let(:public_collection_2) { Collection.create(title: ['Public Collection 2'], collection_type_gid: collection_type.gid, depositor: user.ms_id, visibility: 'open') }
    let(:private_collection) { Collection.create(title: ['Private Collection'], collection_type_gid: collection_type.gid, depositor: user.ms_id, visibility: 'restricted') }

    before do
      work.member_of_collections += [public_collection_1, public_collection_2, private_collection]
    end

    it 'returns only public collection ids' do
      expect(work.member_of_public_collection_ids).to match_array([public_collection_1.id, public_collection_2.id])
    end
  end

  describe "remove_solr_record" do
    let!(:media)                { Media.create(title: ['media']) }
    let!(:specimen)             { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
    let!(:taxonomy)             { Taxonomy.create(title: ['taxonomy']) }
    let!(:cho)                  { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes']) }
    let!(:organization)         { Organization.create(title: ['organization']) }
    let!(:device)               { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let!(:imaging_event)        { ImagingEvent.create(title: ['imaging event'], device_id: [device.id], ie_modality: device.modality) }
    let!(:processing_event)     { ProcessingEvent.create(title: ['processing event']) }

    let!(:media_id)             { media.id }
    let!(:specimen_id)          { specimen.id }
    let!(:taxonomy_id)          { taxonomy.id }
    let!(:cho_id)               { cho.id }
    let!(:organization_id)      { organization.id }
    let!(:device_id)            { device.id }
    let!(:imaging_event_id)     { imaging_event.id }
    let!(:processing_event_id)  { processing_event.id }

    let(:works)                 { [media, specimen, cho, taxonomy, organization, device, imaging_event, processing_event] }

    let(:ids)                   { [media_id, specimen_id, taxonomy_id, cho_id, organization_id, device_id, imaging_event_id, processing_event_id] }

    # in most cases, the remove_solr_record callback should be unnecessary
    context 'corresponding solr records are deleted as expected' do
      before do
        # skip remove_solr_record
        allow_any_instance_of(described_class).to receive(:remove_solr_record).and_return(true)
      end
      it 'solr documents are destroyed without the extra callback' do
        ids.each do |id|
          expect(SolrDocument.find(id)).to be_instance_of(SolrDocument)
        end
        works.each(&:destroy)
        # solr docs don't exist
        ids.each do |id|
          expect{SolrDocument.find(id)}.to raise_error(Blacklight::Exceptions::RecordNotFound)
        end
      end
    end
    context 'corresponding solr records are not deleted as expected' do
      before do
        allow(ActiveFedora::SolrService).to receive(:delete).and_call_original
        # don't actually delete the solr docs
        ids.each do |id|
          allow(ActiveFedora::SolrService).to receive(:delete).with(id).and_return(true)
        end
      end
      it 'solr documents are destroyed by the extra callback' do
        ids.each do |id|
          expect(SolrDocument.find(id)).to be_instance_of(SolrDocument)
        end
        # since the docs aren't deleted when they're supposed to be, delete is called a second time in the callback
        ids.each do |id|
          expect(ActiveFedora::SolrService).to receive(:delete).with(id).twice
        end
        works.each(&:destroy)
      end
    end
  end

  describe '#controlled_value_filter' do
    before do
      works2.each(&:save)
    end
    it 'controlled_value_filter' do
      expect(media1.side).to eq(['Left'])
      expect(media1.media_type).to eq(['CTImageSeries'])
      expect(media1.unit).to eq(['Cm'])
      expect(imagingEvent.pixel_spacing_calibration).to eq(['Fiducial'])
      expect(imagingEvent.target_type).to eq(['Reflection'])
      expect(specimen1.sex).to eq(['Female'])
    end
  end


end
