module Morphosource
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # enable f.field facet format
    include Morphosource::Facets::SearchBuilderFacetParamsBehavior 

    def add_facet_paging_to_solr(solr_params)
      super
  
      return unless facet.present?
      facet_config = blacklight_config.facet_fields[facet]
      contains = blacklight_params[request_keys[:contains]]
      contains_title = blacklight_params[:'facet.containsTitle']
  
      if contains_title.present?
        case facet_config.key
        when "license"
          query_values = mapped_values( Hyrax.config.license_service_class.new, contains_title)
        when "rights_statement"
          query_values = mapped_values( Hyrax.config.rights_statement_service_class.new, contains_title)
        when "device"
          # Perform a lookup on the Solr title field to find matching IDs
          response = fetch_ids_by_title_and_model(contains_title, facet_config.key)
          query_values = response['response']['docs'].map { |doc| doc['id'] }
        else
          # unknown facet key
          query_values = nil
        end
        if query_values.any?
          # facet.contains does not support multiple values.  Use filter query (fq) instead
          solr_params[:fq] ||= []
          solr_params[:fq] << "{!terms f=#{facet_config.field}}#{query_values.join(',')}"
        else
          # If no query_values, add an always-false filter query to ensure no results are returned
          solr_params[:fq] ||= []
          solr_params[:fq] << "{!frange l=1 u=0}1"
        end
      elsif contains.present?
        solr_params[:"f.#{facet_config.field}.facet.contains"] = contains
        solr_params[:"f.#{facet_config.field}.facet.contains.ignoreCase"] = true
      end
    end

    def mapped_values(select_service, contains_value) 
      options = select_service.select_active_options
      matching_terms = options.select { |term| term[0].downcase.include?(contains_value.downcase) }
      matching_ids = matching_terms.map { |term| term[1] }
    end

    private

    # from https://github.com/samvera/hyrax/blob/main/app/search_builders/hyrax/catalog_search_builder.rb
    # original contains a join statement to search work and members which slows down solr queries a ton
    # the {!lucene} gives us the OR syntax
    def new_query
      "{!lucene}#{interal_query(dismax_query)}"
    end

    # Query Solr to fetch IDs by matching title and model
    def fetch_ids_by_title_and_model(title, model)
      solr_service = Blacklight.default_index.connection
      solr_service.get('select', params: {
        q: "title_tesim:\"#{title}\" AND has_model_ssim:#{model.camelcase}",
        fl: 'id',
        rows: 1000
      })
    end

  end
end