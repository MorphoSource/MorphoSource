# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Works::Base do
  let(:organization)    { Organization.create(title: ['organization title']) }
  let(:specimen1)       { BiologicalSpecimen.create(title: ['title'], vouchered: ["Yes"], organization_id: [organization.id], sex: ['female '], date_created:["07/11/2019"]) }
  let(:specimen2)       { BiologicalSpecimen.create(title: ['title'], vouchered: ["No"], organization_id: [organization.id]) }
  let(:media1)          { Media.create(title: ['title'], side:[' left'], media_type:['ctimageseries '], unit:[' cm '], date_created:["7-11-2019"]) }
  let(:media2)          { Media.create(title: ['title']) }
  let(:media3)          { Media.create(title: ['title']) }
  let(:file_set1)       { FileSet.create }
  let(:file_set2)       { FileSet.create }
  let(:file_set3)       { FileSet.create }
  let(:device)          { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
  let(:imagingEvent)    { ImagingEvent.create(title: ['title'], device_id: [device.id.to_s], physical_object_id: [specimen1.id], ie_modality: device.modality, pixel_spacing_calibration:[' fiducial'], target_type: ['Reflection '], date_created:["7/11/2019"]) }
  let(:imagingEvent2)   { ImagingEvent.create(title: ['title'], device_id: [device.id.to_s], physical_object_id: [specimen2.id], ie_modality: device.modality) }
  let(:processingEvent) { ProcessingEvent.create(title: ['title'], date_created:["07-11-2019"]) }
  let(:works)           { [media1, media2, media3, imagingEvent, imagingEvent2, processingEvent, file_set1, file_set2, file_set3] }
  let(:works2)           { [media1, specimen1, imagingEvent, processingEvent] }
  let(:expected_date)  { ["2019-07-11"] }

  describe '#ancestors' do
    before { allow(Hyrax.publisher).to receive(:publish) }

    context 'with a Valkyrie ImagingEventResource as direct parent of Media' do
      let(:child_id) { SecureRandom.uuid }
      let(:ie_resource) { FactoryBot.valkyrie_create(:imaging_event_resource, title: ['ie'], member_ids: [Valkyrie::ID.new(child_id)], with_index: false) }

      before { ie_resource }

      it 'finds the Valkyrie parent via Postgres member_ids inverse reference' do
        media = Media.new(title: ['media'])
        allow(media).to receive(:id).and_return(child_id)
        allow(media).to receive(:member_of).and_return([])

        expect(media.ancestors).to include(ie_resource)
      end
    end

    context 'with a multi-level chain: ProcessingEvent (AF) -> Media (AF) -> ImagingEventResource (Valkyrie)' do
      let(:media_id) { SecureRandom.uuid }
      let(:ie_resource) { FactoryBot.valkyrie_create(:imaging_event_resource, title: ['ie'], member_ids: [Valkyrie::ID.new(media_id)], with_index: false) }

      before { ie_resource }

      it 'finds the Valkyrie ancestor through the full chain' do
        media = Media.new(title: ['media'])
        allow(media).to receive(:id).and_return(media_id)
        allow(media).to receive(:member_of).and_return([])

        pe = ProcessingEvent.new(title: ['pe'])
        allow(pe).to receive(:id).and_return(SecureRandom.uuid)
        allow(pe).to receive(:member_of).and_return([media])

        expect(pe.ancestors).to include(media)
        expect(pe.ancestors).to include(ie_resource)
      end
    end
  end

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
      context 'owner is a user' do
        before do
          media1.owner = owner.ms_id
        end
        it 'returns the owner' do
          expect(subject).to eq(owner.ms_id)
        end
      end
      context 'owner is an organization collection' do
        let(:owner) { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
        before do
          media1.owner = owner.id
        end
        it 'returns the owner' do
          expect(subject).to eq(owner.id)
        end
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
    let(:public_collection_1) { Collection.create(title: ['Public Collection 1'], collection_type_gid: project_collection_type.to_global_id, depositor: user.ms_id, visibility: 'open') }
    let(:public_collection_2) { Collection.create(title: ['Public Collection 2'], collection_type_gid: project_collection_type.to_global_id, depositor: user.ms_id, visibility: 'open') }
    let(:private_collection) { Collection.create(title: ['Private Collection'], collection_type_gid: project_collection_type.to_global_id, depositor: user.ms_id, visibility: 'restricted') }

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
    let!(:cho)                  { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes']) }
    let!(:organization)         { Organization.create(title: ['organization']) }
    let!(:device)               { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
    let!(:imaging_event)        { ImagingEvent.create(title: ['imaging event'], device_id: [device.id.to_s], ie_modality: device.modality) }
    let!(:processing_event)     { ProcessingEvent.create(title: ['processing event']) }

    let!(:media_id)             { media.id }
    let!(:specimen_id)          { specimen.id }
    let!(:cho_id)               { cho.id }
    let!(:organization_id)      { organization.id }
    let!(:device_id)            { device.id.to_s }
    let!(:imaging_event_id)     { imaging_event.id }
    let!(:processing_event_id)  { processing_event.id }

    let(:works)                 { [media, specimen, cho, organization, device, imaging_event, processing_event] }

    let(:ids)                   { [media_id, specimen_id, cho_id, organization_id, device_id, imaging_event_id, processing_event_id] }

    # in most cases, the remove_solr_record callback should be unnecessary
    context 'corresponding solr records are deleted as expected' do
      before do
        # skip remove_solr_record
        allow_any_instance_of(described_class).to receive(:remove_solr_record).and_return(true)
      end
      it 'solr documents are destroyed without the extra callback' do
        allow(Hyrax.publisher).to receive(:publish)
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
        allow(Hyrax.publisher).to receive(:publish)
        ids.each do |id|
          expect(SolrDocument.find(id)).to be_instance_of(SolrDocument)
        end
        # since the docs aren't deleted when they're supposed to be, delete is called again in the callback
        expect(ActiveFedora::SolrService).to receive(:delete).at_least(:once)
        works.each(&:destroy)
      end
    end
  end

  describe '#controlled_value_filter, #date_filter' do
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
    it 'date_filter' do
      expect(media1.date_created).to eq(expected_date)
      expect(imagingEvent.date_created).to eq(expected_date)
      expect(specimen1.date_created).to eq(expected_date)
      expect(processingEvent.date_created).to eq(expected_date)
    end
  end

end
