require 'rails_helper'

RSpec.describe Hyrax::ImagingEventsController, :type => :controller do

  include_context 'update works'

  before do
    contributors.users << user
    contributors.save
    sign_in user
  end

  describe 'creating an imaging event as a child of a specimen' do
    let!(:device)  { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:params)  { { "imaging_event"=> { "device_id" => device.id, "ie_modality" => device.modality.first, "physical_object_id" => [specimen.id] } } }

    it 'updates no objects not created' do
      expect { post :create, params: params
      }.to not_change      { specimen.reload.modified_date }
       .and not_change { taxonomy.reload.modified_date }
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
