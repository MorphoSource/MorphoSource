require 'rails_helper'

RSpec.describe MediaIndexer do
  subject(:solr_document) { MediaIndexer.new(media).generate_solr_document }
  let(:media)             { Media.create(title: ['New Media'], fileset_accessibility: ['restricted_download']) }

  describe 'custom fields' do
    let(:field_values) { {
      fileset_accessibility: media.fileset_accessibility,
      file_set_visibilities: ['restricted'],
      download_groups: ['download_group1', 'download_group2'],
      download_users: ['download_user1', 'download_user2'],
      human_readable_media_type: 'Image',
      modality: "Scanning Electron Microscopy",
      physical_object_type: "Cultural Heritage Object",
      organization_titles: ["Organization 1", "Organization 2"]
    } }

    before do
      field_values.each do |k,v|
        allow(media).to receive(k).and_return(v)
      end
    end

    it 'indexes file_set_visibilities' do
      expect(subject['file_set_visibilities_ssim']).to eq field_values[:file_set_visibilities]
    end
    it 'indexes download_access_group' do
      expect(subject['download_access_group_ssim']).to match_array field_values[:download_groups]
    end
    it 'indexes download_access_person' do
      expect(subject['download_access_person_ssim']).to match_array field_values[:download_users]
    end
    it 'indexes fileset_accessibility' do
      expect(subject['fileset_accessibility_ssim']).to eq field_values[:fileset_accessibility]
    end
    it 'indexes human_readable_media_type' do
      expect(subject['human_readable_media_type_tesim']).to eq field_values[:human_readable_media_type]
      expect(subject['human_readable_media_type_sim']).to eq field_values[:human_readable_media_type]
    end
    it 'indexes media_modality' do
      expect(subject['media_modality_tesim']).to eq field_values[:modality]
      expect(subject['media_modality_sim']).to eq field_values[:modality]
    end
    it 'indexes media_physical_object_type' do
      expect(subject['media_physical_object_type_tesim']).to eq field_values[:physical_object_type]
      expect(subject['media_physical_object_type_sim']).to eq field_values[:physical_object_type]
    end
    it 'indexes media_organization' do
      expect(subject['media_organization_tesim']).to eq field_values[:organization_titles]
      expect(subject['media_organization_sim']).to eq field_values[:organization_titles]
    end
  end
end
