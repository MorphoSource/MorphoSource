module Morphosource
  ##
  # NOTE: We should eventually move to the upcoming official Hyrax::SolrService
  #       https://github.com/samvera/hyrax/blob/master/app/services/hyrax/solr_service.rb
  #
  # Supports some VERY BASIC solr interactions.
  #
  class SolrService

    attr_accessor :query, :args, :result

    def self.prepare_value(v)
      if v.to_s.include? " "
        "\"#{RSolr.solr_escape(v)}\""
      else
        RSolr.solr_escape(v)
      end
    end

    def get(query = nil, args = {})
      if !args.key?(:q)
        if query.present?
          args = args.merge(q: query)
        elsif args[:fq].present? and ( ( args[:fq] || [] ).count == 1 )
          # special case no query and only 1 fq condition, fq condition becomes query
          args = args.merge(q: args[:fq].pop)
        else
          # fallback to always supply query
          args = args.merge(q: "*:*")
        end
      end

      args = args.merge(rows: 999999) unless args.key?(:rows)
      args = args.merge(qt: 'standard') unless args.key?(:qt)

      @result = connection.post('select', data: args) # Switching to post due to URI too long errors
    end

    def get_count(query = nil, args = {})
      args = args.merge(rows: 0)
      get(query, args)
      count
    end

    def get_docs(query = nil, args = {})
      get(query, args)
      result["response"]["docs"]
    end

    def get_facet_fields(query = nil, facet_fields = [], args = {})
      facet_fields = Array(facet_fields)

      args = args.merge(facet: "on") if facet_fields.present?
      args = args.merge("facet.field" => facet_fields) if facet_fields.present?

      get(query, args)
    end

    # autocomplete for tags
    def search_terms(field, query)
      connection.post("terms", data: { "terms.fl" => field, "terms.prefix" => query, "omitHeader" => true } )
    end

    def facet_fields(field_names)
      if result.present? and result["facet_counts"]["facet_fields"].present?
        facet_hash = {}
        facet_result = result["facet_counts"]["facet_fields"]
        field_names.each do |f|
          facet_hash[f] = Hash[*facet_result[f].flatten(1)] if facet_result.key?(f)
        end
        facet_hash
      else
        {}
      end
    end

    def docs
      result["response"]["docs"] if result.present? && result["response"]["docs"].present?
    end

    def count
      result['response']['numFound'].to_i
    end

    private

      def connection
        ActiveFedora::SolrService.instance.conn
      end

      # Wraps ActiveFedora::Base#search_by_id(id, opts)
      # @return [Array<SolrHit>] the response docs wrapped in SolrHit objects
      def search_by_id(id, opts = {})
        # result = Hyrax::SolrService.query("id:#{id}", opts.merge(rows: 1))
        result = []

        raise Hyrax::ObjectNotFoundError, "Object '#{id}' not found in solr" if result.empty?
        result.first
      end
  end
end
