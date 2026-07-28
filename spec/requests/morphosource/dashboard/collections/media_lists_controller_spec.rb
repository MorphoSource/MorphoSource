# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Morphosource::Dashboard::Collections::MediaListsController', type: :request do

  describe 'PATCH update' do
    let(:non_admin)           { FactoryBot.create(:user) }
    # A second persisted resource whose ID we use as the thumbnail reference.
    # Fedora requires thumbnail_id to point to a real node.
    let(:thumbnail_target)    { FactoryBot.create(:media_list, depositor: non_admin.ms_id) }
    let(:media_list_with_doi) do
      FactoryBot.create(:media_list,
                        doi:        ['10.5072/FK2/EXAMPLE'],
                        visibility: 'restricted',
                        depositor:  non_admin.ms_id)
    end

    before do
      media_list_with_doi.thumbnail_id = thumbnail_target.id
      media_list_with_doi.save!
      sign_in non_admin
    end

    context 'when non-admin PATCHes visibility only on a DOI list (no representative_id submitted)' do
      it 'preserves the existing thumbnail_id' do
        patch "/dashboard/media-lists/#{media_list_with_doi.id}",
              params: { media_list: { visibility: 'open' } }
        expect(media_list_with_doi.reload.thumbnail_id).to eq(thumbnail_target.id)
      end
    end
  end

end
