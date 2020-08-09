module Morphosource

    class MediaWorksMemberService < Hyrax::Collections::CollectionMemberService
      
      def all_member_media(current_user, fq_params = [])
        # filter media by depositor and creator
        role_clauses = [
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: current_user.user_key),
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(creator: current_user.user_key)
        ]
        joined_clauses = "(#{role_clauses.join(' OR ')}) AND " + 
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: 'Media')
 
        fq_params << joined_clauses

        response = available_member_works_filter_query(fq_params: fq_params)
#byebug
        return response
      end

      # @api public
      #
      def all_member_media_objects(object_ids = [], object_model = nil, fq_params = [])
        core_fq = "(id:(#{object_ids.join(' OR ')}))"
        core_fq += " AND (#{Solrizer.solr_name('has_model', :symbol)}:#{object_model})" if object_model.present?
        fq_params << core_fq 
        temp = available_member_works_filter_query(fq_params: fq_params)
#byebug
        return temp
      end

      # @api public
      #
      # Works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_member_works_filter_query(fq_params: [])
        query_solr_with_fq(query_builder: works_search_builder, query_params: {}, fq_params: fq_params)
      end

      private

      def works_search_builder
        @works_search_builder ||= Hyrax::CollectionMemberSearchBuilder.new(scope: scope, collection: collection, search_includes_models: :works)
      end

      # @api private
      #
#      def assemble_organization_media_query(organization_object_ids)
#        " OR (#{Solrizer.solr_name('physical_object_id', :stored_searchable)}:(#{organization_object_ids.join(' OR ')}))"
#      end

      # @api private
      #
      def query_solr_with_fq(query_builder:, query_params:, fq_params:)
        initial_fq = query_builder[:fq]
        initial_rows = query_builder[:rows]
        begin
          query_builder.merge(fq: fq_params)
          query_builder.merge(rows: 99999)
          repository.search(query_builder.with(query_params).query)
        ensure
          query_builder.merge(fq: initial_fq)
          query_builder.merge(rows: initial_rows)
        end
      end
    end
end