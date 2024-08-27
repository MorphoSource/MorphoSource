require 'rails_helper'

RSpec.describe MediaListIndexer do
  subject(:solr_document) { MediaListIndexer.new(list).generate_solr_document }

  let(:user)  { FactoryBot.create(:user)}
  let(:doi)   { ['10.17602/M2/L123456'] }
  let(:list)  { FactoryBot.create(:media_list,
                                  depositor: user.ms_id,
                                  visibility: 'restricted',
                                  doi: doi) }

  describe 'property fields' do
    it 'indexes indexes property values' do
      expect(subject['publication_status_si']).to eq('private')
      expect(subject['doi_ssim']).to match_array(doi)
    end
  end

end
