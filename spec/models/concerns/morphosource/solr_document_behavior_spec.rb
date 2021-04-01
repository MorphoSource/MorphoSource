# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Morphosource::SolrDocumentBehavior', type: :model do
  let(:document) { SolrDocument.new(attributes) }

  describe 'object_record_source' do
    context 'record has an idigbio id' do
      let(:attributes) { { "idigbio_uuid_tesim"=> ['idigbioid'] } }

      it 'returns a link to the idigbio id' do
        expect(document.object_record_source).to eq("<a href=\"https://www.idigbio.org/portal/records/idigbioid\">iDigBio</a>")
      end

      it 'returns the raw idigbio url' do
        expect(document.idigbio_url).to eq("https://www.idigbio.org/portal/records/idigbioid")
      end
    end
    context 'record does not have an idigbio id' do
      let(:attributes)  { { } }

      it 'returns user created' do
        expect(document.object_record_source).to eq("User Created")
      end
    end
  end

  describe 'collection_member_count' do
    let!(:collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
    let!(:collection)         { Collection.create(title: ['collection'], collection_type_gid: collection_type.gid) }
    let(:attributes)          { {"id" => collection.id } }

    before do
      allow_any_instance_of(Collection).to receive(:group_member_count).and_return(3)
    end

    it 'returns the number of members in the collection' do
      expect(document.collection_member_count).to eq(3)
    end
  end
end
