# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Hyrax::Ability::CollectionAbility' do
  subject { ability }

  let!(:user)           { User.create(email: 'email@email.com', password: 'password') }
  let(:current_user)    { user }
  let(:ability)         { Ability.new(current_user) }
  let!(:depositor)      { User.create(email: 'email2@email.com', password: 'password') }
  let(:collection)      { Collection.create(id: 'Team', title: ['Team'], depositor: depositor.ms_id, collection_type_gid: team_collection_type.gid) }
  let(:solr_document)   { SolrDocument.new(collection.to_solr) }

  before do
    collection.create_collection_groups
  end

  context 'when admin' do
    before do
      allow(current_user).to receive(:groups).and_return(['admin'])
      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
    end

    it 'allows edit_works and download_works' do
      is_expected.to be_able_to(:edit_works, collection)
      is_expected.to be_able_to(:download_works, collection)
    end
  end

  context 'when manager' do
    before do
      collection.managers << current_user
      collection.managers_group.save

      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)

      collection.reset_access_controls!
    end

    it 'allows edit_works and download_works' do
      is_expected.to be_able_to(:edit_works, collection)
      is_expected.to be_able_to(:download_works, collection)
    end
  end

  context 'when collection work-editor' do
    before do
      collection.editors << current_user
      collection.editors_group.save

      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)

      collection.reset_access_controls!
    end

    it 'allows work-editor related abilities' do
      is_expected.to be_able_to(:view_admin_show_any, Collection)
      is_expected.to be_able_to(:deposit, collection)
      is_expected.to be_able_to(:deposit, solr_document)
      is_expected.to be_able_to(:view_admin_show, collection)
      is_expected.to be_able_to(:view_admin_show, solr_document)
      is_expected.to be_able_to(:read, collection)
      is_expected.to be_able_to(:read, solr_document) # defined in solr_document_ability.rb
      is_expected.to be_able_to(:edit_works, collection)
      is_expected.to be_able_to(:download_works, collection)
    end

    it 'denies non-work-editor related abilities' do
      is_expected.not_to be_able_to(:manage, Collection)
      is_expected.not_to be_able_to(:manage_any, Collection)
      is_expected.not_to be_able_to(:edit, collection)
      is_expected.not_to be_able_to(:edit, solr_document) # defined in solr_document_ability.rb
      is_expected.not_to be_able_to(:update, collection)
      is_expected.not_to be_able_to(:update, solr_document) # defined in solr_document_ability.rb
      is_expected.not_to be_able_to(:destroy, collection)
      is_expected.not_to be_able_to(:destroy, solr_document) # defined in solr_document_ability.rb
    end
  end

  context 'when depositor' do
    before do
      collection.depositors << current_user
      collection.depositors_group.save

      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)

      collection.reset_access_controls!
    end

    it 'denies edit_works and download_works' do
      is_expected.not_to be_able_to(:edit_works, collection)
      is_expected.not_to be_able_to(:download_works, collection)
    end
  end

  context 'when collection downloader' do
    before do
      collection.downloaders << current_user
      collection.downloaders_group.save

      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)

      collection.reset_access_controls!
    end

    it 'allows downloader related abilities' do
      is_expected.to be_able_to(:view_admin_show_any, Collection)
      is_expected.to be_able_to(:view_admin_show, collection)
      is_expected.to be_able_to(:view_admin_show, solr_document)
      is_expected.to be_able_to(:read, collection)
      is_expected.to be_able_to(:read, solr_document) # defined in solr_document_ability.rb
      is_expected.to be_able_to(:download_works, collection)
    end

    it 'denies non-downloader related abilities' do
      is_expected.not_to be_able_to(:manage, Collection)
      is_expected.not_to be_able_to(:manage_any, Collection)
      is_expected.not_to be_able_to(:edit, collection)
      is_expected.not_to be_able_to(:edit, solr_document) # defined in solr_document_ability.rb
      is_expected.not_to be_able_to(:update, collection)
      is_expected.not_to be_able_to(:update, solr_document) # defined in solr_document_ability.rb
      is_expected.not_to be_able_to(:deposit, collection)
      is_expected.not_to be_able_to(:deposit, solr_document)
      is_expected.not_to be_able_to(:destroy, collection)
      is_expected.not_to be_able_to(:destroy, solr_document) # defined in solr_document_ability.rb
      is_expected.not_to be_able_to(:edit_works, collection)
    end
  end

  context 'when viewer' do
    before do
      collection.viewers << current_user
      collection.viewers_group.save

      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)

      collection.reset_access_controls!
    end

    it 'denies edit_works and download_works' do
      is_expected.not_to be_able_to(:edit_works, collection)
      is_expected.not_to be_able_to(:download_works, collection)
    end
  end
end
