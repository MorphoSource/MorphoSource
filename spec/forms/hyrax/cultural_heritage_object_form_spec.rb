# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe Hyrax::CulturalHeritageObjectForm do

  let(:required_fields) { [ :vouchered ] }

  describe 'class attributes' do

    it 'has expected metadata terms' do
      expect(described_class.terms).to include(:bibliographic_citation, :catalog_number, :collection_code, :latitude,
                                               :longitude, :numeric_time, :original_location, :periodic_time,
                                               :vouchered, :cho_type, :material, :short_title)

      expect(described_class.terms).to_not include(:keyword, :license, :rights_statement, :subject, :title, :language,
                                                   :source, :resource_type)
    end

    it 'has expected required metadata terms' do
      expect(described_class.required_fields).to match_array(required_fields)
    end

    it 'has expected single valued metadata terms' do
      expect(described_class.single_valued_fields).to match_array([ :bibliographic_citation, :catalog_number,
                                                                    :collection_code, :date_created, :description,
                                                                    :latitude, :longitude, :numeric_time,
                                                                    :original_location, :publisher, :vouchered,
                                                                    :creator, :short_title ])
    end

  end

  describe 'instance methods' do

    let(:work) { CulturalHeritageObject.new }
    let(:ability) { double }
    let(:controller) { double }

    subject { described_class.new(work, ability, controller)}

    it 'has the expected primary metadata terms' do
      expect(subject.primary_terms).to match_array(required_fields + [ :short_title, :bibliographic_citation,
                                                                       :based_near, :catalog_number, :collection_code,
                                                                       :date_created, :identifier, :related_url ])
    end

  end

end
