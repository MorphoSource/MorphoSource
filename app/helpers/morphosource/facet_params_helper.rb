module Morphosource
  # Override Blacklight methods to help replace default f[field][] format for facet URL parameter with f.field
  module FacetParamsHelper
    ##
    # Get the values of the facet set in the blacklight query string
    def facet_params field
      config = facet_configuration_for_field(field)

      params["f.#{config.key}"] || ( params[:f][config.key] if params[:f] )
    end

    ##
    # Check if the query has any constraints defined (a query, facet, etc)
    #
    # @param [Hash] localized_params query parameters
    # @return [Boolean]
    def query_has_constraints?(localized_params = params)
      localized_params[:q].present? || facet_localized_params(localized_params).present?
    end

    def facet_localized_params(localized_params)
      localized_params[:f] || localized_params.select { |param, value| param.start_with?("f.") && value.present? }
    end

    ##
    # Render the facet constraints
    # @param [Hash] localized_params query parameters
    # @return [String]
    def render_constraints_filters(localized_params = params)
      return "".html_safe unless facet_localized_params(localized_params)
      path = controller.search_state_class.new(localized_params, blacklight_config, controller)
      content = []
      facet_localized_params(localized_params).each_pair do |facet,values|
        facet = facet.sub("f.", "")
        content << render_filter_element(facet, values, path)
      end

      safe_join(content.flatten, "\n")
    end
  end
end