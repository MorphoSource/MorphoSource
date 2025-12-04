# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::MediaListsController, type: :controller do

  let(:user)        { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)   { User.create(email: 'depositor@email.com', password: 'password') }
  let(:media_list)  { MediaList.create(title: ['media list'], collection_type_gid: media_list_collection_type.to_global_id, depositor: depositor.ms_id, creator: [depositor.ms_id]) }

  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::MediaListPresenter) }
  end

  describe 'default_collection_type' do
    let!(:media_list_collection_type)  { Hyrax::CollectionType.create(title: 'Media List') }

    it { expect(subject.send(:default_collection_type).title).to eq("Media List") }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(MediaList) }
  end

  describe 'mint_doi' do
    let(:admin) {FactoryBot.create(:admin) }
    let(:doi)   { '10.5072/FK2/MYSAMPLEDOI' }
    before do
      sign_in admin
      allow(controller).to receive(:load_collection).and_return(media_list)
    end

    context 'when DOI minting is successful' do
      before do
        allow_any_instance_of(MediaList).to receive(:mint_doi).and_return(doi)
      end
      it 'redirects to edit page after minting DOI' do
        post :mint_doi, params: { id: media_list.id }
        expect(response).to redirect_to(media_list_edit_path(media_list))
        expect(flash[:notice]).to match(/Successfully minted DOI:/)
      end
    end

    context 'when DOI minting fails' do
      context 'due to an exception' do
        before do
          allow_any_instance_of(MediaList).to receive(:mint_doi).and_raise(StandardError.new("Minting error"))
        end
        it 'sets an error flash message and redirects to edit page' do
          post :mint_doi, params: { id: media_list.id }
          expect(response).to redirect_to(media_list_edit_path(media_list))
          expect(flash[:error]).to eq("DOI minting failed: Minting error.")
        end
      end
      context 'due to a minting exception' do
        before do
          allow_any_instance_of(MediaList).to receive(:mint_doi).and_return(StandardError.new("Minting error"))
        end
        it 'sets an error flash message and redirects to edit page' do
          post :mint_doi, params: { id: media_list.id }
          expect(response).to redirect_to(media_list_edit_path(media_list))
          expect(flash[:error]).to match("DOI minting failed: Minting error.")
        end
      end
      context 'due to nil DOI' do
        before do
          allow_any_instance_of(MediaList).to receive(:mint_doi).and_return(nil)
        end
        it 'sets an error flash message and redirects to edit page' do
          post :mint_doi, params: { id: media_list.id }
          expect(response).to redirect_to(media_list_edit_path(media_list))
          expect(flash[:error]).to eq("DOI minting failed. Please check the logs for details.")
        end
      end
    end
  end
end
