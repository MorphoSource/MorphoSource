require 'rails_helper'

RSpec.describe MediaListIndexer do
  subject(:solr_document) { MediaListIndexer.new(list).generate_solr_document }

  let(:user)  { FactoryBot.create(:user)}
  let(:list)  { FactoryBot.create(:media_list, depositor: user.ms_id, visibility: 'restricted') }

  context 'list with media' do
    let(:media)         { FactoryBot.create(:media) }

    before do
      media.member_of_collections += [list]
      media.save!
    end

    it 'indexes publication_status_si fields' do
      expect(subject['publication_status_si']).to eq('private')
    end
  end
end
