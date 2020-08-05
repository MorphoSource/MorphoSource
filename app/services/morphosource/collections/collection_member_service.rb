# frozen_string_literal: true
module Morphosource
  module Collections
    # Responsible for retrieving collection members
    class CollectionMemberService < Hyrax::Collections::CollectionMemberService
      
      # @api public
      #
      # Media works which are 
      # 1) direct members of given collection, 
      # 2) members of subcollections of given collection (if collection is nestable), and 
      # 3) media representing physical objects from collection-linked media
      def all_member_media(organization_object_ids = [], fq_params = [])
        core_fq = "(#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:#{collection.id})"
        core_fq += assemble_multiple_collection_query if collection.collection_type.nestable?
        core_fq += assemble_organization_media_query(organization_object_ids) if organization_object_ids.present? 
        fq_params << core_fq
        fq_params << "#{Solrizer.solr_name('has_model', :symbol)}:#{Media}"
        available_member_works_filter_query(fq_params: fq_params)
      end

      # @api public
      #
      def all_member_media_objects(object_ids = [], object_model = nil, fq_params = [])
        core_fq = "(id:(#{object_ids.join(' OR ')}))"
        core_fq += "AND (#{Solrizer.solr_name('has_model', :symbol)}:#{object_model})" if object_model.present?
        fq_params << core_fq 
        available_member_works_filter_query(fq_params: fq_params)
      end

      # @api public
      #
      # Works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_member_works_filter_query(fq_params: [])
        query_solr_with_fq(query_builder: works_search_builder, query_params: {}, fq_params: fq_params)
      end

      private

      # @api private
      #
      def assemble_multiple_collection_query
        subcollection_ids = available_member_subcollections.documents.map { |s| s['id'] }
        if subcollection_ids.present?
          " OR (#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:(#{subcollection_ids.join(' OR ')}))"
        else
          ""
        end
      end

      # @api private
      #
      def assemble_organization_media_query(organization_object_ids)
        " OR (#{Solrizer.solr_name('physical_object_id', :stored_searchable)}:(#{organization_object_ids.join(' OR ')}))"
      end

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
end