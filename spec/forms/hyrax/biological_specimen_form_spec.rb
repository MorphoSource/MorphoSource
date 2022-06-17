# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe Hyrax::BiologicalSpecimenForm do

  let(:required_fields) { [] }

  describe 'class attributes' do

    it 'has expected metadata terms' do
      expect(described_class.terms).to include(:bibliographic_citation, :catalog_number, :collection_code, :institution_code, :latitude,
                                               :longitude, :numeric_time, :original_location, :periodic_time,
                                               :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen,
                                               :occurrence_id, :sex, :canonical_taxonomy)

      expect(described_class.terms).to_not include(:keyword, :license, :rights_statement, :subject, :title, :language,
                                                   :source, :resource_type)
    end

    it 'has expected required metadata terms' do
      expect(described_class.required_fields).to match_array(required_fields)
    end

    it 'has expected single valued metadata terms' do
      expect(described_class.single_valued_fields).to match_array([ :address,
                                                                    :canonical_taxonomy,
                                                                    :catalog_number,
                                                                    :city,
                                                                    :collection_code,
                                                                    :context,
                                                                    :country,
                                                                    :current_location,
                                                                    :date_created,
                                                                    :dating_method,
                                                                    :description,
                                                                    :dimensions,
                                                                    :formation,
                                                                    :idigbio_recordset_id,
                                                                    :idigbio_uuid,
                                                                    :institution_code,
                                                                    :is_type_specimen,
                                                                    :latitude,
                                                                    :longitude,
                                                                    :numeric_time,
                                                                    :occurrence_id,
                                                                    :organization_relationship,
                                                                    :original_location,
                                                                    :provenance_date,
                                                                    :provenance_details,
                                                                    :provenance_location,
                                                                    :provenance_name,
                                                                    :publisher,
                                                                    :sex,
                                                                    :state_province,
                                                                    :vouchered ])
    end

  end

  describe 'instance methods' do

    let(:work) { BiologicalSpecimen.new }
    let(:ability) { double }
    let(:controller) { double }

    subject { described_class.new(work, ability, controller)}

    it 'has the expected primary metadata terms' do
      expect(subject.primary_terms).to match_array(required_fields + [:based_near,
                                                                      :bibliographic_citation,
                                                                      :canonical_taxonomy,
                                                                      :catalog_number,
                                                                      :collection_code,
                                                                      :date_created,
                                                                      :identifier,
                                                                      :institution_code,
                                                                      :organization_relationship,
                                                                      :related_url])
    end

  end

end
