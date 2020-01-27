module Qa::Authorities
  class FindCulturalHeritageObjects < Qa::Authorities::FindWorks

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
        institution_code = doc.institution_code
        latitude = doc.latitude
        longitude = doc.longitude
        numeric_time = doc.numeric_time
        original_location = doc.original_location
        periodic_time = doc.periodic_time
        vouchered = doc.vouchered
        cho_type = doc.cho_type
        material = doc.material
        short_title = doc.short_title
        {
          id: id,
          label: title,
          value: id,
          bibliographic_citation: bibliographic_citation,
          catalog_number: catalog_number,
          collection_code: collection_code,
          institution_code: institution_code,
          latitude: latitude,
          longitude: longitude,
          numeric_time: numeric_time,
          original_location: original_location,
          periodic_time: periodic_time,
          vouchered: vouchered,
          cho_type: cho_type,
          material: material,
          short_title: short_title
        }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end