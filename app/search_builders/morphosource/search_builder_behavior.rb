module Morphosource
  module SearchBuilderBehavior

    # Sort results by request param, or use default otherwise
    def add_sorting_to_solr(solr_parameters)
      if search_state.params[:sort].present?
        solr_parameters[:sort] = search_state.params[:sort] 
      else
        default_sort = blacklight_config.default_sort_field&.sort || "score desc"
        solr_parameters[:sort] = default_sort
      end
    end
  end
end