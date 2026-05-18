require 'rails_helper'

RSpec.describe Hyrax::ImagingEventsController, :type => :controller do
  let(:user)                      { User.create(email: 'email@email.com', password: 'password') }
  let(:contributors)              { Role.create(name: 'contributor') }

  let(:organization)              { Organization.create(title: ['old title']) }
  let(:taxonomy)                  { valkyrie_create(:taxonomy_resource, title: ['old title']) }
  let(:specimen)                  { BiologicalSpecimen.create(title: ['old title'], vouchered: ['Yes'], organization_id: [organization.id], taxonomy_id: [taxonomy.id]) }
  let(:device)                    { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ["MagneticResonanceImaging"])}
  let(:imaging_event)             { ImagingEvent.create(title: ['old title'], ie_modality: device.modality, device_id: [device.id.to_s], physical_object_id: [specimen.id]) }
  let(:media1)                    { Media.create(title: ['old title']) }
  let(:processing_event)          { ProcessingEvent.create(title: ['old title']) }
  let(:media2)                    { Media.create(title: ['old title']) }
  let(:specimen_works)            { [imaging_event, media1, processing_event, media2] }

  let(:old_organization_doc)      { SolrDocument.find(organization.id) }
  let(:old_taxonomy_doc)          { SolrDocument.find(taxonomy.id) }
  let(:old_specimen_doc)          { SolrDocument.find(specimen.id) }
  let(:old_imaging_event_doc)     { SolrDocument.find(imaging_event.id) }
  let(:old_media1_doc)            { SolrDocument.find(media1.id) }
  let(:old_processing_event_doc)  { SolrDocument.find(processing_event.id) }
  let(:old_media2_doc)            { SolrDocument.find(media2.id) }

  let(:old_docs)                  { [old_organization_doc, old_taxonomy_doc, old_specimen_doc, old_imaging_event_doc, old_media1_doc, old_processing_event_doc, old_media2_doc] }

  let(:new_organization_doc)      { SolrDocument.find(organization.id) }
  let(:new_taxonomy_doc)          { SolrDocument.find(taxonomy.id) }
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

    contributors.users << user
    contributors.save
    sign_in user
  end

  describe 'creating an imaging event as a child of a specimen' do
    let!(:device)  { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
    let(:params)  { { "imaging_event"=> { "device_id" => device.id.to_s, "ie_modality" => device.modality.first, "physical_object_id" => [specimen.id] } } }

    it 'updates no objects not created' do
      expect { post :create, params: params
      }.to not_change      { specimen.reload.modified_date }
       .and not_change { Hyrax.query_service.find_by(id: taxonomy.id).date_modified }
       .and not_change { organization.reload.modified_date }
       .and not_change { imaging_event.reload.modified_date }
       .and not_change { media1.reload.modified_date }
       .and not_change { processing_event.reload.modified_date }
       .and not_change { media2.reload.modified_date }
    end

    it 'updates no solr docs not created' do
      # load before version of solr docs
      old_docs

      post :create, params: params

      # associated works are not reindexed
      expect(old_specimen_doc['_version_']).to eq(new_specimen_doc['_version_'])
      expect(old_organization_doc['_version_']).to eq(new_organization_doc['_version_'])
      expect(old_taxonomy_doc['_version_']).to eq(new_taxonomy_doc['_version_'])
      expect(old_imaging_event_doc['_version_']).to eq(new_imaging_event_doc['_version_'])
      expect(old_media1_doc['_version_']).to eq(new_media1_doc['_version_'])
      expect(old_processing_event_doc['_version_']).to eq(new_processing_event_doc['_version_'])
      expect(old_media2_doc['_version_']).to eq(new_media2_doc['_version_'])
    end
  end
end
