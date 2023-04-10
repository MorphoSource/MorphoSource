module Qa::Authorities
  class FindBiologicalSpecimens < Qa::Authorities::FindWorks
    self.search_builder_class = Morphosource::FindPhysicalObjectsSearchBuilder

    include MorphosourceHelper

    def search(_q, controller)
      # The My::FindWorksSearchBuilder expects a current_user
      return [] unless controller.current_user
      repo = CatalogController.new.repository
      builder = search_builder(controller)
      response = repo.search(builder)
      docs = response.documents
      docs.map do |doc|
        id = doc.id
        title = doc.title
        bibliographic_citation = doc.bibliographic_citation
        catalog_number = doc.catalog_number
        collection_code = doc.collection_code
        canonical_taxonomy = doc.canonical_taxonomy
        institution_code = doc.institution_code
        latitude = doc.latitude
        longitude = doc.longitude
        numeric_time = doc.numeric_time
        original_location = doc.original_location
        periodic_time = doc.periodic_time
        vouchered = doc.vouchered
        idigbio_recordset_id = doc.idigbio_recordset_id
        idigbio_uuid = doc.idigbio_uuid
        is_type_specimen = doc.is_type_specimen
        occurrence_id = doc.occurrence_id
        sex = doc.sex
        source_of_record = source_of_record(idigbio_uuid, idigbio_recordset_id)
        organization_id = doc.organization_id 
        {
          id: id,
          label: title,
          value: id,
          bibliographic_citation: bibliographic_citation,
          catalog_number: catalog_number,
          collection_code: collection_code,
          canonical_taxonomy: canonical_taxonomy,
          institution_code: institution_code,
          latitude: latitude,
          longitude: longitude,
          numeric_time: numeric_time,
          original_location: original_location,
          periodic_time: periodic_time,
          vouchered: vouchered,
          idigbio_recordset_id: idigbio_recordset_id,
          idigbio_uuid: idigbio_uuid,
          is_type_specimen: is_type_specimen,
          occurrence_id: occurrence_id,
          sex: sex,
          source_of_record: source_of_record,
          organization_id: organization_id
        }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end