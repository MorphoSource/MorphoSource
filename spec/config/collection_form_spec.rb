require 'rails_helper'
RSpec.describe Hyrax::Forms::CollectionForm do
  let(:terms) { [:title, :creator, :contributor, :description, :keyword, :representative_id, :thumbnail_id, :based_near, :related_url, :visibility, :collection_type_gid] }
  let(:required_fields) { [:title] }
  let(:primary_terms) { [:title, :description] }
  let(:secondary_terms) { [:creator, :contributor, :keyword, :based_near, :related_url] }

  describe 'class attributes' do

    it 'has expected metadata terms' do
      expect(described_class.terms).to match_array(terms)
    end

    it 'has expected required metadata terms' do
      expect(described_class.required_fields).to match_array(required_fields)
    end
  end

  describe 'instance methods' do

    let(:collection) { Collection.new }
    let(:ability) { double }
    let(:repository) { double }

    subject { described_class.new(collection, ability, repository)}

    it 'has the expected primary metadata terms' do
      expect(subject.primary_terms).to match_array(primary_terms)
    end

    it 'has the expected secondary metadata terms' do
      expect(subject.secondary_terms).to match_array(secondary_terms)
    end
  end
end
