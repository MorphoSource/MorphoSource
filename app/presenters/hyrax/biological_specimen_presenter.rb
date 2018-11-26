# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  class BiologicalSpecimenPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :bibliographic_citation, :catalog_number, :collection_code, :numeric_time, :original_location,
             :periodic_time, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, :occurrence_id, :sex,
             :geographic_coordinates,  to: :solr_document
  end
end
