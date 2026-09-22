module Morphosource
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # enable f.field facet format
    include Morphosource::Facets::SearchBuilderFacetParamsBehavior
    include Morphosource::Facets::SolrTitleLookup

    def add_facet_paging_to_solr(solr_params)
      super

      return unless facet.present?
      facet_config = blacklight_config.facet_fields[facet]
      contains = blacklight_params[blacklight_config.facet_paginator_class.request_keys[:contains]]
      contains_title = blacklight_params[:'facet.containsTitle']

      if contains_title.present?
        # for certain facet keys (e.g. license, rights_statement, device), lookup an existing source (e.g. Yaml file) to find matching IDs
        add_facet_filter(facet_config, contains_title, solr_params)
      elsif contains.present?
        solr_params[:"f.#{facet_config.field}.facet.contains"] = contains
        solr_params[:"f.#{facet_config.field}.facet.contains.ignoreCase"] = true
      end
    end

    private

    def add_facet_filter(facet_config, contains_title, solr_params)
      matching_terms = case facet_config.key
                       when 'license'
                         custom_list = Hyrax::LicenseService.new.select_all_options
                         custom_list.select { |title, _url| title.downcase.include?(contains_title.downcase) }.map(&:last)
                       when 'rights_statement'
                         custom_list = Hyrax::RightsStatementService.new.select_all_options
                         custom_list.select { |title, _url| title.downcase.include?(contains_title.downcase) }.map(&:last)
                       when 'device', 'team', 'project', 'media_list', 'seq_section_list'
                         fetch_ids_by_title(contains_title, facet_config.key)
                       when 'owner'
                         # owners can be users or organizations
                         fetch_owner_ids_by_name(contains_title)
                       when 'depositor'
                         # depositors are always users
                         fetch_user_ids_by_name(contains_title)
                       else
                         []
                       end

      if matching_terms.any?
        solr_params[:fq] ||= []
        solr_params[:fq] << "{!terms f=#{facet_config.field}}#{matching_terms.join(',')}"
      else
        solr_params[:fq] ||= []
        solr_params[:fq] << "{!frange l=1 u=0}1"
      end
    end

    # from https://github.com/samvera/hyrax/blob/main/app/search_builders/hyrax/catalog_search_builder.rb
    # original contains a join statement to search work and members which slows down solr queries a ton
    # the {!lucene} gives us the OR syntax
    def new_query
      "{!lucene}#{interal_query(dismax_query)}"
    end
  end
end
