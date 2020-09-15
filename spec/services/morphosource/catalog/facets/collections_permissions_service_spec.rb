require 'rails_helper'

RSpec.describe Morphosource::Catalog::Facets::CollectionsPermissionsService do
  let(:collection_type)       { Hyrax::CollectionType.create(title: 'Team', machine_id: 'team') }
  let(:depositor)             { User.create(email: 'email@email.com', password: 'password') }

  # public collections
  let(:public_col_1)           { Collection.create(title: ['Public Col 1'], depositor: depositor.ms_id, collection_type_gid: collection_type.gid, visibility: 'open') }
  let(:public_col_2)           { Collection.create(title: ['Public Col 2'], depositor: depositor.ms_id, collection_type_gid: collection_type.gid, visibility: 'open') }
  let(:public_col_3)           { Collection.create(title: ['Public Col 3'], depositor: depositor.ms_id, collection_type_gid: collection_type.gid, visibility: 'open') }
  let(:public_collections)     { [public_col_1, public_col_2, public_col_3] }
  let!(:public_collection_ids) { [public_col_1.id, public_col_2.id, public_col_3.id] }

  # private collections
  let(:private_col_1)         { Collection.create(title: ['Private Col 1'], depositor: depositor.ms_id, collection_type_gid: collection_type.gid, visibility: 'restricted') }
  let(:private_col_2)         { Collection.create(title: ['Private Col 2'], depositor: depositor.ms_id, collection_type_gid: collection_type.gid, visibility: 'restricted') }
  let(:private_col_3)         { Collection.create(title: ['Private Col 3'], depositor: depositor.ms_id, collection_type_gid: collection_type.gid, visibility: 'restricted') }
  let(:private_collections)   { [private_col_1, private_col_2, private_col_3] }

  describe '.ids_for_collection_facet' do
    let!(:all_collection_ids) { [private_col_1.id, private_col_2.id, private_col_3.id, public_col_1.id, public_col_2.id, public_col_3.id] }
    let(:user)                    { User.create(email: 'user@email.com', password: 'password') }

    subject { described_class.ids_for_collection_facet(ability: Ability.new(user)) }

    before do
      private_collections.each do |collection|
        collection.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
      end
    end

    context 'user is an admin' do
      before do
        admin = Role.create(name: 'admin')
        admin.users << user
        admin.save
      end

      it 'returns all collection ids' do
        expect(subject).to match_array(all_collection_ids)
      end
    end

    context 'user does not have access to any private collections' do
      it 'returns only the public collection ids' do
        expect(subject).to match_array(public_collection_ids)
      end
    end

    context 'user is a collection manager for the private collections' do
      before do
        private_collections.each do |collection|
          collection.managers << user
          collection.managers_group.save
        end
      end
      it 'returns all collection ids' do
        expect(subject).to match_array(all_collection_ids)
      end
    end

    context 'user is a collection editor for the private collections' do
      before do
        private_collections.each do |collection|
          collection.editors << user
          collection.editors_group.save
        end
      end
      it 'returns all collection ids' do
        expect(subject).to match_array(all_collection_ids)
      end
    end

    context 'user is a collection depositor for the private collections' do
      before do
        private_collections.each do |collection|
          collection.depositors << user
          collection.depositors_group.save
        end
      end
      it 'returns private and public collection ids' do
        expect(subject).to match_array(all_collection_ids)
      end
    end

    context 'user is a collection downloader for the private collections' do
      before do
        private_collections.each do |collection|
          collection.downloaders << user
          collection.downloaders_group.save
        end
      end
      it 'returns private and public collection ids' do
        expect(subject).to match_array(all_collection_ids)
      end
    end

    context 'user is a collection viewer for the private collections' do
      before do
        private_collections.each do |collection|
          collection.viewers << user
          collection.viewers_group.save
        end
      end
      it 'returns private and public collection ids' do
        expect(subject).to match_array(all_collection_ids)
      end
    end

    context 'user has access to only one of the private collections' do
      before do
        private_col_1.viewers << user
        private_col_1.viewers_group.save
      end
      it 'returns one private collection and all public collections' do
        expect(subject).to match_array([private_col_1.id] +  public_collection_ids)
      end
    end
  end

  describe '.public_collection_ids' do
    subject { described_class.public_collection_ids }
    it 'returns all public collection ids' do
      expect(subject).to match_array(public_collection_ids)
    end
  end
end
