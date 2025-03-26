module Morphosource
  module Solr
    module CulturalHeritageObject

      CULTURAL_HERITAGE_OBJECT_PROPERTIES = %w[aat_attribute
                                               aat_attribute_label
                                               aat_material
                                               aat_material_label
                                               aat_period
                                               aat_period_label
                                               aat_type
                                               aat_type_label
                                               ark
                                               cho_attribute
                                               cho_type
                                               material
                                               periodic_time_label
                                               short_title
                                               tgn_label].freeze

      def combined_attribute_terms
        (Array(self['cho_attribute_tesim']) + Array(self['aat_attribute_label_tesim'])).compact.sort_by{|t| t.downcase}
      end

      def combined_material_terms
        (Array(self['material_tesim']) + Array(self['aat_material_label_tesim'])).compact.sort_by{|t| t.downcase}
      end

      def combined_type_terms
        (Array(self['cho_type_tesim']) + Array(self['aat_type_label_tesim'])).compact.sort_by{|t| t.downcase}
      end
    end
  end
end
