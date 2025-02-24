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
        # for certain facet keys (e.g. license, rights_statement), lookup an existing source (e.g. Yaml file) to find matching IDs
        case facet_config.key
        when 'license'
          custom_list = YAML.load_file(Rails.root.join('config', 'authorities', 'licenses.yml'))
          matching_terms = custom_list['terms'].select { |term| term['term'].downcase.include?(contains_title.downcase) }
          matching_ids = matching_terms.map { |term| term['id'] }
          if matching_ids.any?
            solr_params[:fq] ||= []
            solr_params[:fq] << "{!terms f=#{facet_config.field}}#{matching_ids.join(',')}"
          else
            solr_params[:fq] ||= []
            solr_params[:fq] << "{!frange l=1 u=0}1"
          end
        when 'rights_statement'
          rights_statements = YAML.load_file(Rails.root.join('config', 'authorities', 'rights_statements.yml'))
          matching_terms = rights_statements['terms'].select { |term| term['term'].downcase.include?(contains_title.downcase) }
          matching_ids = matching_terms.map { |term| term['id'] }
          if matching_ids.any?
            solr_params[:fq] ||= []
            solr_params[:fq] << "{!terms f=#{facet_config.field}}#{matching_ids.join(',')}"
          else
            solr_params[:fq] ||= []
            solr_params[:fq] << "{!frange l=1 u=0}1"
          end
        when 'device'          
          response = fetch_ids_by_title(contains_title, facet_config.key)
          matching_ids = response['response']['docs'].map { |doc| doc['id'] }
          if matching_ids.any?
            solr_params[:fq] ||= []
            solr_params[:fq] << "{!terms f=#{facet_config.field}}#{matching_ids.join(',')}"
          else
            # If no matching_ids, add an always-false filter query to ensure no results are returned
            solr_params[:fq] ||= []
            solr_params[:fq] << "{!frange l=1 u=0}1"
          end
        end
      elsif contains.present?
        solr_params[:"f.#{facet_config.field}.facet.contains"] = contains
        solr_params[:"f.#{facet_config.field}.facet.contains.ignoreCase"] = true
      end
    end

    private

    # from https://github.com/samvera/hyrax/blob/main/app/search_builders/hyrax/catalog_search_builder.rb
    # original contains a join statement to search work and members which slows down solr queries a ton
    # the {!lucene} gives us the OR syntax
    def new_query
      "{!lucene}#{interal_query(dismax_query)}"
    end

    # Query Solr to fetch IDs by matching title and model
    def fetch_ids_by_title(title, facet_key)
      # Perform a lookup on the Solr title field to find matching IDs
      case facet_key
      when 'device'
        query = 'has_model_ssim:Device'
      else
        query = 'has_model_ssim:unknown'
        Rails.logger.warn("Unknown model for facet key: #{facet_config.key}")
      end

      full_query = "#{query} AND title_tesim:\"#{title}\""
      solr_service = Blacklight.default_index.connection
      solr_service.get('select', params: {
        q: full_query,
        fl: 'id, has_model_ssim, title_tesim',
        rows: 999999
      })
    end

  end
end