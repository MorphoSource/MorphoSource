require 'rails_helper'

RSpec.describe Morphosource::DoiBehavior do
  let(:media_list)  { MediaList.create(title: ['media list title'], depositor: depositor.ms_id, doi: doi) }
  let(:depositor)   { FactoryBot.create(:user) }
  let(:media)       { Media.create(title: ['media title'], depositor: depositor.ms_id, doi: doi) }

  describe '#prevent_doi_deletion' do
    context 'when DOI is present' do
      let!(:doi) { ['10.1234/existing.doi'] }

      it 'prevents deletion by throwing :abort' do
        byebug
        expect { media_list.destroy }.to_not change { MediaList.exists?(media_list.id) }
        expect { media.destroy }.to_not change { Media.exists?(media.id) }
      end
    end

    context 'when DOI is empty' do
      let!(:doi) { [] }

      it 'allows deletion to proceed' do
        expect { media_list.destroy! }.to change { MediaList.exists?(media_list.id) }.from(true).to(false)
        expect { media.destroy! }.to change { Media.exists?(media.id) }.from(true).to(false)
      end
    end
  end

  describe '#mint_doi' do
    context 'when DOI exists' do
      let!(:doi) { ['10.1234/existing.doi'] }

      it 'raises an error' do
        expect { media_list.mint_doi('http://example.com') }.to raise_error(StandardError)
        expect { media.mint_doi('http://example.com') }.to raise_error(StandardError)
      end
    end
  end
end
