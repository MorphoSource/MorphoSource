# frozen_string_literal: true
module Morphosource
  module Collections
    # Responsible for retrieving collection members
    class CollectionSetMemberService 
      attr_reader :scope, :params, :collections, :collection
      delegate :repository, to: :scope
      
      def initialize(scope:, user:, collections:, params:)
        @scope = scope
        @user = user
        @collections = collections
        @params = params
      end

      def media_count_for_edit(collections)
        return 99
      end


      # @api public
      #
      # Collections which are members of the given collection
      # @return [Blacklight::Solr::Response] {up to 50 solr documents}
      def available_member_subcollections(coll)
        query_solr(query_builder: subcollections_search_builder(coll), query_params: params_for_subcollections)
      end

      # @api public
      #
      # Media works which are 
      # 1) direct members of given collection, 
      # 2) members of subcollections of given collection (if collection is nestable), and 
      # 3) media representing physical objects from collection-linked media
      def all_member_media(organization_object_ids = [], fq_params = [])
        collection_ids = []
        subcoll_fq = ""
        collections.each do |collection_doc|
          collection_ids << collection_doc.id
          collection = Collection.find(collection_doc.id)
          subcoll_fq += assemble_multiple_collection_query_for(collection) if collection.collection_type.nestable?
        end
        core_fq = assemble_user_media_query
        core_fq += " OR (#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:(#{collection_ids.join(' OR ')}))" if collection_ids.length > 0
        core_fq += subcoll_fq if subcoll_fq.present?
        core_fq += assemble_organization_media_query(organization_object_ids) if organization_object_ids.present? 
        fq_params << core_fq
        fq_params << "#{Solrizer.solr_name('has_model', :symbol)}:#{Media}"

        response = available_member_works_filter_query(fq_params: fq_params)
        return response
      end

      def assemble_user_media_query
        # add media by depositor and creator (not thru collections)
        role_clauses = [
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: @user.user_key),
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(creator: @user.user_key)
        ]
        joined_clauses = "(#{role_clauses.join(' OR ')}) "
        return joined_clauses
      end

      # @api public
      #
      def all_member_media_objects(object_ids = [], object_model = nil, fq_params = [])
        core_fq = "(id:(#{object_ids.join(' OR ')}))"
        core_fq += " AND (#{Solrizer.solr_name('has_model', :symbol)}:#{object_model})" if object_model.present?
        fq_params << core_fq 
        available_member_works_filter_query(fq_params: fq_params)
      end

      # @api public
      #
      # Works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_member_works_filter_query(fq_params: [])
        query_solr_with_fq(query_builder: works_search_builder, query_params: params[:q], fq_params: fq_params)
      end

      private

      # @api private
      #
#      def assemble_multiple_collection_query
#        subcollection_ids = available_member_subcollections.documents.map { |s| s['id'] }
#        if subcollection_ids.present?
#          " OR (#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:(#{subcollection_ids.join(' OR ')}))"
#        else
#          ""
#        end
#      end

      def assemble_multiple_collection_query_for(coll)
        subcollection_ids = available_member_subcollections(coll).documents.map { |s| s['id'] }
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
        initial_q = query_builder[:q]
        initial_fq = query_builder[:fq]
        initial_rows = query_builder[:rows]
        begin
          query_builder.merge(q: query_params)
          query_builder.merge(fq: fq_params)
          query_builder.merge(rows: initial_rows) # was 99999
          #repository.search(query_builder.with(query_params).query)
          repository.search(query_builder.query)
        ensure
          query_builder.merge(q: initial_q)
          query_builder.merge(fq: initial_fq)
          query_builder.merge(rows: initial_rows)
        end
      end



      # from app/services/hyrax/collections/collection_member_service.rb

        # @api private
        #
        # set up a member search builder for works only
        # @return [CollectionMemberSearchBuilder] new or existing
        def works_search_builder
          @works_search_builder ||= Hyrax::CollectionSetMemberSearchBuilder.new(scope: scope, collections: collections, search_includes_models: :works)
        end

        # @api private
        #
        # set up a member search builder for collections only
        # @return [CollectionMemberSearchBuilder] new or existing
        def subcollections_search_builder(collection)
          @subcollections_search_builder ||= Hyrax::CollectionMemberSearchBuilder.new(scope: scope, collection: collection, search_includes_models: :collections)
        end

        # @api private
        #
        # set up a member search builder for returning work ids only
        # @return [CollectionMemberSearchBuilder] new or existing
        def work_ids_search_builder
          @work_ids_search_builder ||= Hyrax::CollectionSetMemberSearchBuilder.new(scope: scope, collections: collections, search_includes_models: :works)
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

        # @api private
        #
        # Blacklight pagination still needs to be overridden and set up for the subcollections.
        # @return <Hash> the additional inputs required for the subcollection member search builder
        def params_for_subcollections
          # To differentiate current page for works vs subcollections, we have to use a sub_collection_page
          # param. Map this to the page param before querying for subcollections, if it's present
          params[:page] = params.delete(:sub_collection_page)
          params
        end

    end
  end
end