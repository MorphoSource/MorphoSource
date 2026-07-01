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

  describe 'check_for_doi' do
    let(:non_admin)           { FactoryBot.create(:user) }
    let(:admin)               { FactoryBot.create(:admin) }
    let(:media_list_with_doi) { FactoryBot.create(:media_list, doi: ['10.5072/FK2/EXAMPLE']) }

    context 'when user is not admin and media list has a DOI' do
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
      end

      it 'redirects to edit path with doi_warning error flash' do
        expect(controller).to receive(:redirect_to).with(media_list_edit_path(media_list_with_doi))
        controller.send(:check_for_doi)
        expect(controller.flash[:error]).to eq(I18n.t('morphosource.dashboard.collections.media_list.edit.doi_warning'))
      end
    end

    context 'when user is admin and media list has a DOI' do
      before do
        sign_in admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
      end

      it 'does not redirect' do
        expect(controller).not_to receive(:redirect_to)
        controller.send(:check_for_doi)
      end
    end
  end

  describe 'check_visibility_direction' do
    let(:non_admin) { FactoryBot.create(:user) }
    let(:admin)     { FactoryBot.create(:admin) }

    context 'when non-admin attempts to change visibility from open to restricted on a DOI list' do
      let(:media_list_with_doi) { FactoryBot.create(:media_list, doi: ['10.5072/FK2/EXAMPLE'], visibility: 'open') }
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(media_list: { visibility: 'restricted' })
        )
      end

      it 'redirects to edit path with doi_visibility_error flash' do
        expect(controller).to receive(:redirect_to).with(media_list_edit_path(media_list_with_doi))
        controller.send(:check_visibility_direction)
        expect(controller.flash[:error]).to eq(I18n.t('morphosource.dashboard.collections.media_list.edit.doi_visibility_error'))
      end
    end

    context 'when non-admin changes visibility from restricted to open on a DOI list' do
      let(:media_list_with_doi) { FactoryBot.create(:media_list, doi: ['10.5072/FK2/EXAMPLE'], visibility: 'restricted') }
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(media_list: { visibility: 'open' })
        )
      end

      it 'does not redirect' do
        expect(controller).not_to receive(:redirect_to)
        controller.send(:check_visibility_direction)
      end
    end

    context 'when admin attempts to change visibility from open to restricted on a DOI list' do
      let(:media_list_with_doi) { FactoryBot.create(:media_list, doi: ['10.5072/FK2/EXAMPLE'], visibility: 'open') }
      before do
        sign_in admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(media_list: { visibility: 'restricted' })
        )
      end

      it 'does not redirect' do
        expect(controller).not_to receive(:redirect_to)
        controller.send(:check_visibility_direction)
      end
    end

    context 'when non-admin attempts to change visibility on a list with no DOI' do
      let(:media_list_no_doi) { FactoryBot.create(:media_list, visibility: 'open') }
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_no_doi)
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(media_list: { visibility: 'restricted' })
        )
      end

      it 'does not redirect' do
        expect(controller).not_to receive(:redirect_to)
        controller.send(:check_visibility_direction)
      end
    end

    context 'when non-admin submits a non-public, non-restricted visibility (e.g. authenticated) on a public DOI list' do
      let(:media_list_with_doi) { FactoryBot.create(:media_list, doi: ['10.5072/FK2/EXAMPLE'], visibility: 'open') }
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(media_list: { visibility: 'authenticated' })
        )
      end

      it 'redirects to edit path with doi_visibility_error flash' do
        expect(controller).to receive(:redirect_to).with(media_list_edit_path(media_list_with_doi))
        controller.send(:check_visibility_direction)
        expect(controller.flash[:error]).to eq(I18n.t('morphosource.dashboard.collections.media_list.edit.doi_visibility_error'))
      end
    end
  end

  describe 'strip_doi_protected_fields' do
    let(:non_admin)           { FactoryBot.create(:user) }
    let(:admin)               { FactoryBot.create(:admin) }
    let(:media_list_with_doi) { FactoryBot.create(:media_list, doi: ['10.5072/FK2/EXAMPLE']) }
    let(:media_list_no_doi)   { FactoryBot.create(:media_list) }
    # Reuse the same params object so in-place slice! mutations are observable.
    let(:ml_params) { ActionController::Parameters.new(media_list: { title: 'New Title', description: 'desc', visibility: 'open' }) }

    context 'when non-admin submits extra fields on a DOI list' do
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
        allow(controller).to receive(:params).and_return(ml_params)
      end

      it 'strips all params except visibility' do
        controller.send(:strip_doi_protected_fields)
        expect(ml_params[:media_list].keys).to eq(['visibility'])
      end
    end

    context 'when admin submits extra fields on a DOI list' do
      before do
        sign_in admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
        allow(controller).to receive(:params).and_return(ml_params)
      end

      it 'does not strip any params' do
        controller.send(:strip_doi_protected_fields)
        expect(ml_params[:media_list].keys).to include('title', 'description', 'visibility')
      end
    end

    context 'when non-admin submits fields on a list with no DOI' do
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_no_doi)
        allow(controller).to receive(:params).and_return(ml_params)
      end

      it 'does not strip any params' do
        controller.send(:strip_doi_protected_fields)
        expect(ml_params[:media_list].keys).to include('title', 'description', 'visibility')
      end
    end
  end

  describe 'add_doi_message' do
    let(:non_admin)           { FactoryBot.create(:user) }
    let(:admin)               { FactoryBot.create(:admin) }
    let(:media_list_with_doi) { FactoryBot.create(:media_list, doi: ['10.5072/FK2/EXAMPLE']) }
    let(:media_list_no_doi)   { FactoryBot.create(:media_list) }

    context 'when non-admin edits a DOI list' do
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
      end

      it 'sets flash.now[:alert] with doi_message' do
        controller.send(:add_doi_message)
        expect(controller.flash.now[:alert]).to eq(I18n.t('morphosource.dashboard.collections.media_list.edit.doi_message'))
      end
    end

    context 'when admin edits a DOI list' do
      before do
        sign_in admin
        controller.instance_variable_set(:@collection, media_list_with_doi)
      end

      it 'does not set flash.now[:alert]' do
        controller.send(:add_doi_message)
        expect(controller.flash.now[:alert]).to be_nil
      end
    end

    context 'when non-admin edits a list with no DOI' do
      before do
        sign_in non_admin
        controller.instance_variable_set(:@collection, media_list_no_doi)
      end

      it 'does not set flash.now[:alert]' do
        controller.send(:add_doi_message)
        expect(controller.flash.now[:alert]).to be_nil
      end
    end
  end
end
