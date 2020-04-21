require 'rails_helper'

RSpec.describe MediaIndexer do
  subject(:solr_document) { MediaIndexer.new(media).generate_solr_document }
  let(:media)             { Media.create(title: ['New Media']) }

  describe 'custom fields' do
    let(:file_set_visibilities) { ['restricted'] }
    let(:download_groups)       { ['download_group1', 'download_group2'] }
    let(:download_users)        { ['download_user1', 'download_user2'] }

    before do
      allow(media).to receive(:file_set_visibilities).and_return(file_set_visibilities)
      allow(media).to receive(:download_groups).and_return(download_groups)
      allow(media).to receive(:download_users).and_return(download_users)
    end

    it 'indexes file_set_visibilities' do
      expect(subject['file_set_visibilities_ssim']).to eq file_set_visibilities
    end
    it 'indexes download_access_group' do
      expect(subject['download_access_group_ssim']).to match_array download_groups
    end
    it 'indexes download_access_person' do
      expect(subject['download_access_person_ssim']).to match_array download_users
    end
  end
end
