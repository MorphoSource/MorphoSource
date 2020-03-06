# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Hyrax::Ability::CollectionAbility' do
  subject { ability }

  let!(:user)           { User.create(email: 'email@email.com', password: 'password') }
  let(:current_user)    { user }
  let(:ability)         { Ability.new(current_user) }
  let!(:depositor)      { User.create(email: 'email2@email.com', password: 'password') }
  let(:collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 'team') }

  context 'when collection editor' do
    let!(:collection)    { Collection.create(id: 'Team', title: ['Team'], depositor: depositor.ms_id, collection_type_gid: collection_type.gid) }
    let!(:solr_document) { SolrDocument.new(collection.to_solr) }

    before do
      collection.create_collection_groups
      collection.editors << current_user
      collection.editors_group.save

      Hyrax::Collections::PermissionsCreateService.create_ms_template(collection: collection)

      collection.reset_access_controls!
    end

    it 'allows editor related abilities' do
      is_expected.to be_able_to(:view_admin_show_any, Collection)
      is_expected.to be_able_to(:deposit, collection)
      is_expected.to be_able_to(:deposit, solr_document)
      is_expected.to be_able_to(:view_admin_show, collection)
      is_expected.to be_able_to(:view_admin_show, solr_document)
      is_expected.to be_able_to(:read, collection)
      is_expected.to be_able_to(:read, solr_document) # defined in solr_document_ability.rb
    end

    it 'denies non-editor related abilities' do 
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
end
