# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe Hyrax::BiologicalSpecimenForm do

  let(:required_fields) { [ :institution, :title, :vouchered ] }

  describe 'class attributes' do

    it 'has expected metadata terms' do
      expect(described_class.terms).to include(:bibliographic_citation, :catalog_number, :collection_code, :institution,
                                               :latitude, :longitude, :numeric_time, :original_location, :periodic_time,
                                               :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen,
                                               :occurrence_id, :sex)

      expect(described_class.terms).to_not include(:keyword, :license, :rights_statement, :subject, :language, :source,
                                                   :resource_type)
    end

    it 'has expected required metadata terms' do
      expect(described_class.required_fields).to match_array(required_fields)
    end

    it 'has expected single valued metadata terms' do
      expect(described_class.single_valued_fields).to match_array([ :bibliographic_citation, :title, :catalog_number,
                                                                    :collection_code, :date_created, :description,
                                                                    :institution, :latitude, :longitude, :numeric_time,
                                                                    :original_location, :publisher, :vouchered,
                                                                    :idigbio_recordset_id, :idigbio_uuid,
                                                                    :is_type_specimen, :occurrence_id, :sex ])
    end

  end

  describe 'instance methods' do

    let(:work) { BiologicalSpecimen.new }
    let(:ability) { double }
    let(:controller) { double }

    subject { described_class.new(work, ability, controller)}

    it 'has the expected primary metadata terms' do
      expect(subject.primary_terms).to match_array(required_fields + [ :bibliographic_citation, :based_near,
                                                                       :catalog_number, :collection_code, :date_created,
                                                                       :identifier, :related_url ])
    end

  end

end
