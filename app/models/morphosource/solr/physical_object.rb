module Morphosource
  module Solr
    module PhysicalObject

      # properties shared by biological specimens and cultural heritage objects
      PHYSICAL_OBJECT_PROPERTIES = %w[bibliographic_citation
                                      catalog_number
                                      context
                                      current_location
                                      dating_method
                                      dimensions
                                      formation
                                      latitude
                                      longitude
                                      numeric_time
                                      organization_id
                                      original_location
                                      periodic_time
                                      provenance_details
                                      provenance_name
                                      vouchered]

      def geographic_coordinates
        if (latitude && longitude)
          "Latitude: " + latitude[0] + ", Longitude: " + longitude[0]
        elsif latitude
          "Latitude: " + latitude[0]
        elsif longitude
          "Longitude: " + longitude[0]
        end
      end

      def member_ids
        self[Solrizer.solr_name('member_ids', :symbol)]
      end

      def related_media_ids
        self[Solrizer.solr_name('related_media_ids', :symbol)]
      end

    end
  end
end
