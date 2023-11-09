module Morphosource
  module Facets
    # Enables search builder to use facet field f.field format in addition to default f[name][] format
    module SearchBuilderFacetParamsBehavior
      def add_facet_fq_to_solr(solr_parameters)
        super
  
        # Add fq params with f.<facet> format
        blacklight_params
          .select { |param, value| param.to_s.start_with?("f.") && value.present? }
          .each do |param, value|
            facet_field = param.to_s.sub("f.", "") 
            Array(value).reject(&:blank?).each do |v|
              solr_parameters.append_filter_query facet_value_to_fq_string(facet_field, v)
            end
          end
      end
    end
  end
end