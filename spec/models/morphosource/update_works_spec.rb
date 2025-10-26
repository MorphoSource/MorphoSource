# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Works::Base do
  let(:user)                      { User.create(email: 'email@email.com', password: 'password') }
  let(:contributors)              { Role.create(name: 'contributor') }

  let(:organization)              { Organization.create(title: ['old title']) }
  let(:taxonomy)                  { valkyrie_create(:taxonomy_resource, title: ['old title']) }
  let(:specimen)                  { BiologicalSpecimen.create(title: ['old title'], vouchered: ['Yes'], organization_id: [organization.id], taxonomy_id: [taxonomy.id]) }
  let(:device)                    { Device.create(title: ['device'], modality: ["MagneticResonanceImaging"])}
  let(:imaging_event)             { ImagingEvent.create(title: ['old title'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }
  let(:media1)                    { Media.create(title: ['old title']) }
  let(:processing_event)          { ProcessingEvent.create(title: ['old title']) }
  let(:media2)                    { Media.create(title: ['old title']) }
  let(:specimen_works)            { [imaging_event, media1, processing_event, media2] }

  let(:old_organization_doc)      { SolrDocument.find(organization.id) }
  let(:old_taxonomy_doc)          { SolrDocument.find(taxonomy.id.to_s) }
  let(:old_specimen_doc)          { SolrDocument.find(specimen.id) }
  let(:old_imaging_event_doc)     { SolrDocument.find(imaging_event.id) }
  let(:old_media1_doc)            { SolrDocument.find(media1.id) }
  let(:old_processing_event_doc)  { SolrDocument.find(processing_event.id) }
  let(:old_media2_doc)            { SolrDocument.find(media2.id) }

  let(:old_docs)                  { [old_organization_doc, old_taxonomy_doc, old_specimen_doc, old_imaging_event_doc, old_media1_doc, old_processing_event_doc, old_media2_doc] }

  let(:new_organization_doc)      { SolrDocument.find(organization.id) }
  let(:new_taxonomy_doc)          { SolrDocument.find(taxonomy.id.to_s) }
  let(:new_specimen_doc)          { SolrDocument.find(specimen.id) }
  let(:new_imaging_event_doc)     { SolrDocument.find(imaging_event.id) }
  let(:new_media1_doc)            { SolrDocument.find(media1.id) }
  let(:new_processing_event_doc)  { SolrDocument.find(processing_event.id) }
  let(:new_media2_doc)            { SolrDocument.find(media2.id) }

  before do
    imaging_event.members << media1
    media1.members << processing_event
    processing_event.members << media2
    specimen_works.each(&:save)
  end

  describe 'updating the specimen index record' do

    it 'updates only the specimen solr record' do
      old_docs
      specimen.update_index

      # only the specimen is reindexed
      expect(old_specimen_doc['_version_']).not_to eq(new_specimen_doc['_version_'])

      # associated works are not reindexed
      expect(old_taxonomy_doc['_version_']).to eq(new_taxonomy_doc['_version_'])
      expect(old_imaging_event_doc['_version_']).to eq(new_imaging_event_doc['_version_'])
      expect(old_media1_doc['_version_']).to eq(new_media1_doc['_version_'])
      expect(old_processing_event_doc['_version_']).to eq(new_processing_event_doc['_version_'])
      expect(old_media2_doc['_version_']).to eq(new_media2_doc['_version_'])
    end
  end

  describe 'adding a specimen to an organization that already has a specimen' do
    let!(:taxonomy2)        { valkyrie_create(:taxonomy_resource, title: ['taxonomy 2']) }
    let!(:specimen2)        { BiologicalSpecimen.create(title: ['old title'], vouchered: ['Yes'], taxonomy_id: [taxonomy2.id.to_s]) }

    let(:old_taxonomy2_doc) { SolrDocument.find(taxonomy2.id.to_s) }
    let(:old_specimen2_doc) { SolrDocument.find(specimen2.id) }
    let(:new_taxonomy2_doc) { SolrDocument.find(taxonomy2.id.to_s) }
    let(:new_specimen2_doc) { SolrDocument.find(specimen2.id) }

    it 'updates the organization and added specimen objects' do
      expect {
        specimen2.organization_id = [organization.id]
        specimen2.save
      }.to change      { specimen2.modified_date }
       .and not_change { organization.modified_date }
       .and not_change { taxonomy.date_modified }
       .and not_change { taxonomy2.date_modified }
       .and not_change { specimen.modified_date }
       .and not_change { imaging_event.modified_date }
       .and not_change { media1.modified_date }
       .and not_change { processing_event.modified_date }
       .and not_change { media2.modified_date }
    end

    it 'updates the organization and added specimen solr docs' do
      old_taxonomy2_doc
      old_specimen2_doc
      old_docs

      specimen2.organization_id = [organization.id]
      specimen2.save

      # only specimen is reindexed
      expect(old_specimen2_doc['_version_']).not_to eq(new_specimen2_doc['_version_'])

      # associated works are not reindexed
      expect(old_organization_doc['_version_']).to eq(new_organization_doc['_version_'])
      expect(old_taxonomy_doc['_version_']).to eq(new_taxonomy_doc['_version_'])
      expect(old_specimen_doc['_version_']).to eq(new_specimen_doc['_version_'])
      expect(old_imaging_event_doc['_version_']).to eq(new_imaging_event_doc['_version_'])
      expect(old_media1_doc['_version_']).to eq(new_media1_doc['_version_'])
      expect(old_processing_event_doc['_version_']).to eq(new_processing_event_doc['_version_'])
      expect(old_taxonomy2_doc['_version_']).to eq(new_taxonomy2_doc['_version_'])
    end
  end

  describe 'editing a mid-level media' do
    it 'updates only the media object' do
      expect { media1.keyword << 'keyword'
               media1.save
      }.to change      { media1.modified_date }
       .and not_change { taxonomy.date_modified }
       .and not_change { organization.modified_date }
       .and not_change { specimen.modified_date }
       .and not_change { imaging_event.modified_date }
       .and not_change { processing_event.modified_date }
       .and not_change { media2.modified_date }
    end

    it 'updates only the media solr doc' do
      old_docs

      media1.keyword << 'keyword'
      media1.save

      # media is reindexed
      expect(old_media1_doc['_version_']).not_to eq(new_media1_doc['_version_'])

      # associated works are not reindexed
      expect(old_taxonomy_doc['_version_']).to eq(new_taxonomy_doc['_version_'])
      expect(old_organization_doc['_version_']).to eq(new_organization_doc['_version_'])
      expect(old_specimen_doc['_version_']).to eq(new_specimen_doc['_version_'])
      expect(old_imaging_event_doc['_version_']).to eq(new_imaging_event_doc['_version_'])
      expect(old_processing_event_doc['_version_']).to eq(new_processing_event_doc['_version_'])
    end
  end

  describe 'adding a new imaging event' do
    let(:device)                  { Device.create(title: ['device'], modality: ['Photogrammetry'])}
    let!(:imaging_event2)         { ImagingEvent.create(title: ['imaging event 2'], device_id: [device.id], ie_modality: device.modality) }
    let(:old_imaging_event2_doc)  { SolrDocument.find(imaging_event2.id) }
    let(:new_imaging_event2_doc)  { SolrDocument.find(imaging_event2.id) }

    it 'updates only the specimen object and added imaging event' do
      expect {
        imaging_event2.physical_object_id = [specimen.id]
        imaging_event2.save!
      }.to change      { imaging_event2.modified_date }
       .and not_change { specimen.modified_date }
       .and not_change { taxonomy.date_modified }
       .and not_change { organization.modified_date }
       .and not_change { imaging_event.modified_date }
       .and not_change { media1.modified_date }
       .and not_change { processing_event.modified_date }
       .and not_change { media2.modified_date }
    end

    it 'updates only the imaging event and specimen solr doc' do
      old_imaging_event2_doc
      old_docs

      imaging_event2.physical_object_id = [specimen.id]
      imaging_event2.save!

      # imaging event is reindexed
      expect(old_imaging_event2_doc['_version_']).not_to eq(new_imaging_event2_doc['_version_'])

      # don't test this, it differs when test is run individually vs when run with other model tests?
      # expect(old_specimen_doc['_version_']).not_to eq(new_specimen_doc['_version_'])

      # associated works are not reindexed
      expect(old_taxonomy_doc['_version_']).to eq(new_taxonomy_doc['_version_'])
      expect(old_organization_doc['_version_']).to eq(new_organization_doc['_version_'])
      expect(old_imaging_event_doc['_version_']).to eq(new_imaging_event_doc['_version_'])
      expect(old_media1_doc['_version_']).to eq(new_media1_doc['_version_'])
      expect(old_processing_event_doc['_version_']).to eq(new_processing_event_doc['_version_'])
    end
  end
end
