require 'rails_helper'

RSpec.describe Hyrax::BiologicalSpecimensController, :type => :controller do

  include_context 'update works'

  before do
    contributors.users << user
    contributors.save
    sign_in user
  end

  describe 'creating a specimen as a child of an organization' do

    let(:params) { { "biological_specimen"=> { "vouchered"=>"Yes", "work_parents_attributes"=> { '0' => { 'id' => organization.id, '_destroy' => 'false' } } } } }

    it 'updates only the organization object' do
      expect { post :create, params: params
      }.to change      { organization.reload.modified_date }
       .and not_change { taxonomy.reload.modified_date }
       .and not_change { specimen.reload.modified_date }
       .and not_change { imaging_event.reload.modified_date }
       .and not_change { media1.reload.modified_date }
       .and not_change { processing_event.reload.modified_date }
       .and not_change { media2.reload.modified_date }
    end

    it 'updates only the organization solr' do
      # load before version of solr docs
      old_docs

      post :create, params: params

      # only the organization is reindexed
      expect(old_organization_doc['_version_']).not_to eq(new_organization_doc['_version_'])

      # associated works are not reindexed
      expect(old_imaging_event_doc['_version_']).to eq(new_imaging_event_doc['_version_'])
      expect(old_media1_doc['_version_']).to eq(new_media1_doc['_version_'])
      expect(old_processing_event_doc['_version_']).to eq(new_processing_event_doc['_version_'])
      expect(old_media2_doc['_version_']).to eq(new_media2_doc['_version_'])
    end
  end
end

RSpec.describe Hyrax::ImagingEventsController, :type => :controller do

  include_context 'update works'

  before do
    contributors.users << user
    contributors.save
    sign_in user
  end

  describe 'creating an imaging event as a child of a specimen' do

    let(:params) { { "imaging_event"=> { "work_parents_attributes"=> { '0' => { 'id' => specimen.id, '_destroy' => 'false' } } } } }

    it 'updates only the specimen object' do
      expect { post :create, params: params
      }.to change      { specimen.reload.modified_date }
       .and not_change { taxonomy.reload.modified_date }
       .and not_change { organization.reload.modified_date }
       .and not_change { imaging_event.reload.modified_date }
       .and not_change { media1.reload.modified_date }
       .and not_change { processing_event.reload.modified_date }
       .and not_change { media2.reload.modified_date }
    end

    it 'updates only the specimen solr' do
      # load before version of solr docs
      old_docs

      post :create, params: params

      # only the specimen is reindexed
      expect(old_specimen_doc['_version_']).not_to eq(new_specimen_doc['_version_'])

      # associated works are not reindexed
      expect(old_organization_doc['_version_']).to eq(new_organization_doc['_version_'])
      expect(old_taxonomy_doc['_version_']).to eq(new_taxonomy_doc['_version_'])
      expect(old_imaging_event_doc['_version_']).to eq(new_imaging_event_doc['_version_'])
      expect(old_media1_doc['_version_']).to eq(new_media1_doc['_version_'])
      expect(old_processing_event_doc['_version_']).to eq(new_processing_event_doc['_version_'])
      expect(old_media2_doc['_version_']).to eq(new_media2_doc['_version_'])
    end
  end
end
