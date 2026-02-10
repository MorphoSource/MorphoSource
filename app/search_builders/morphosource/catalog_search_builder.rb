module Morphosource
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # enable f.field facet format
    include Morphosource::Facets::SearchBuilderFacetParamsBehavior

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
                         response = fetch_ids_by_title(contains_title, facet_config.key)
                         response['response']['docs'].map { |doc| doc['id'] }
                        when 'owner', 'depositor'
                         fetch_ms_ids_by_name(contains_title)
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

    # Query Solr to fetch IDs by matching title and model
    def fetch_ids_by_title(title, facet_key)
      # Perform a lookup on the Solr title field to find matching IDs
      case facet_key
      when 'device'
        query = 'has_model_ssim:Device'
      when 'team', 'project'
        query = 'has_model_ssim:Collection'
      when 'media_list'
        query = 'has_model_ssim:MediaList'
      when 'seq_section_list'
        query = 'has_model_ssim:SequentialSectionList'
      else
        query = 'has_model_ssim:unknown'
        Rails.logger.warn("Unknown model for facet key: #{facet_config.key}")
      end

      full_query = "#{query} AND title_tesim:\"#{title}\""
      solr_service = Blacklight.default_index.connection
      solr_service.get('select', params: {
        q: full_query,
        fl: 'id',
        rows: 999999
      })
    end

    def fetch_ms_ids_by_name(name)
      User.where('display_name ILIKE ?', "%#{name}%").pluck(:ms_id).map(&:to_s)
    end

  end
end