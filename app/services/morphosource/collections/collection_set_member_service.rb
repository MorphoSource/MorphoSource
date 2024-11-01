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

      # @api public
      #
      # Collections which are members of the given collection
      # @return [Blacklight::Solr::Response] {up to 50 solr documents}
      def available_member_subcollections(coll_id)
        query_solr(query_builder: subcollections_search_builder(coll_id), query_params: params_for_subcollections)
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
          if is_team? collection_doc['collection_type_gid_ssim']&.first
            #collection = Collection.find(collection_doc.id)
            #subcoll_fq += assemble_multiple_collection_query_for(collection_doc.id) if collection.collection_type.nestable?
            subcoll_fq += assemble_multiple_collection_query_for(collection_doc.id)
          end
        end
        core_fq = assemble_user_media_query
        core_fq += " OR (#{ActiveFedora.index_field_mapper.solr_name('member_of_collection_ids', :symbol)}:(#{collection_ids.join(' OR ')}))" if collection_ids.length > 0
        core_fq += subcoll_fq if subcoll_fq.present?
        core_fq += assemble_organization_media_query(organization_object_ids) if organization_object_ids.present? 
        fq_params << core_fq
        fq_params << "#{ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)}:#{Media}"

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
        core_fq += " AND (#{ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)}:#{object_model})" if object_model.present?
        fq_params << core_fq 
        available_member_works_filter_query(fq_params: fq_params, object_model: object_model)
      end

      # @api public
      #
      # Works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_member_works_filter_query(fq_params: [], object_model: nil)
        case object_model.to_s
          when "BiologicalSpecimen"
            rows = @params[:brows]
          when "CulturalHeritageObject"
            rows = @params[:crows]
          else
            rows = @params[:rows]
          end
        rows = rows.presence || Hyrax.config.teams_show_work_item_rows
        page = @params[:page].presence || 1
        start = ((page.to_i - 1) * rows.to_i).to_s
        query_solr_with_fq(query_builder: media_search_builder, query_params: params[:q], fq_params: fq_params, rows: rows, start: start)
      end

      def is_project?(collection_type)
        collection_type.split('/').last == '2'
      end

      def is_team?(collection_type)
        collection_type.split('/').last == '1'
      end

      private

        def assemble_multiple_collection_query_for(coll_id)
          subcollection_ids = available_member_subcollections(coll_id).documents.map { |s| s['id'] }
          if subcollection_ids.present?
            " OR (#{ActiveFedora.index_field_mapper.solr_name('member_of_collection_ids', :symbol)}:(#{subcollection_ids.join(' OR ')}))"
          else
            ""
          end
        end

        # @api private
        #
        def assemble_organization_media_query(organization_object_ids)
          " OR (#{ActiveFedora.index_field_mapper.solr_name('physical_object_id', :stored_searchable)}:(#{organization_object_ids.join(' OR ')}))"
        end

        # @api private
        #
        def query_solr_with_fq(query_builder:, query_params:, fq_params:, rows: 10, start: 0)
          initial_q = query_builder[:q]
          initial_fq = query_builder[:fq]
          initial_rows = query_builder.rows
          initial_start = query_builder.start
          begin
            query_builder.merge(q: query_params)
            query_builder.merge(fq: fq_params)
            query_builder.merge('facet.limit' => -1)
            query_builder.rows = rows
            query_builder.start = start
            repository.search(query_builder.query)
          ensure
            query_builder.merge(q: initial_q)
            query_builder.merge(fq: initial_fq)
            query_builder.merge('facet.limit' => -1)
            query_builder.rows = initial_rows
            query_builder.start = initial_start
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

        def media_search_builder
          @works_search_builder ||= Hyrax::CollectionSetMemberSearchBuilder.new(scope: scope, collections: collections, search_includes_models: :media)
        end

        # @api private
        #
        # set up a member search builder for collections only
        # @return [CollectionMemberSearchBuilder] new or existing
        def subcollections_search_builder(collection_id)
          @subcollections_search_builder ||= Morphosource::CollectionMemberSearchBuilder.new(scope: scope, collection_id: collection_id, search_includes_models: :collections)
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
          params2 = params.deep_dup
          params2[:page] = params2.delete(:sub_collection_page)
          params2
        end

    end
  end
end