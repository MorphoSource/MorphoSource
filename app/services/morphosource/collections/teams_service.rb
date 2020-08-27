module Morphosource
  module Collections
    class TeamsService 
      attr_reader :scope, :params
      delegate :repository, to: :scope
      
      def initialize(scope:, user:, params:)
        @scope = scope
        @user = user
        @params = params
      end

      def all_collections_by_type(collection_type_id, fq_params = [])
        fq_params << "#{Solrizer.solr_name('has_model', :symbol)}:#{Collection}"
        fq_params << "(#{Solrizer.solr_name('collection_type_gid', :symbol)}:\"gid://morpho-source-sf/hyrax-collectiontype/#{collection_type_id}\")"

        response = available_collections_filter_query(fq_params: fq_params)
        return response
      end

      # @return [Blacklight::Solr::Response]
      def available_collections_filter_query(fq_params: [])
        query_solr_with_fq(query_builder: ms_collections_search_builder, query_params: params[:q], fq_params: fq_params)
      end

      private

      # @api private
      #
      def query_solr_with_fq(query_builder:, query_params:, fq_params:)
        initial_q = query_builder[:q]
        initial_fq = query_builder[:fq]
        initial_rows = query_builder[:rows]
        begin
          query_builder.merge(q: query_params)
          query_builder.merge(fq: fq_params)
          query_builder.merge(rows: 99999)
          #repository.search(query_builder.with(query_params).query)
          repository.search(query_builder.query)
        ensure
          query_builder.merge(q: initial_q)
          query_builder.merge(fq: initial_fq)
          query_builder.merge(rows: initial_rows)
        end
      end

      def ms_collections_search_builder
        @ms_collections_search_builder ||= Morphosource::My::MsCollectionsSearchBuilder.new(scope: scope)
      end

      # @api private
      #
      def query_solr(query_builder:, query_params:)
        repository.search(query_builder.with(query_params).query)
      end

      # @api private
      #
      def query_solr_with_field_selection(query_builder:, fl:)
        repository.search(query_builder.merge(fl: fl).query)
      end

    end
  end
end