module Morphosource
  module Solr
    module CulturalHeritageObject

      CULTURAL_HERITAGE_OBJECT_PROPERTIES = %w[aat_attributes
                                               aat_material
                                               aat_type
                                               cho_attributes
                                               cho_type
                                               material
                                               short_title].freeze


      # concatenates aat_attributes & cho_attributes
      def object_attributes
        self[Solrizer.solr_name('object_attributes', :symbol)]
      end

      def object_material
        self[Solrizer.solr_name('object_material', :symbol)]
      end

      def object_type
        self[Solrizer.solr_name('object_type', :symbol)]
      end

    end
  end
end
