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
        core_fq += assemble_multiple_collection_query if collection.respond_to?(:collection_type) && collection.collection_type.nestable?
        core_fq += assemble_organization_media_query(organization_object_ids) if organization_object_ids.present?
        fq_params << "#{Solrizer.solr_name('has_model', :symbol)}:#{Media}"
        available_media_works_filter_query(fq_params: fq_params, core_fq: core_fq)
      end

      # @api public
      #
      def all_member_media_objects(object_ids = [], object_model = nil, fq_params = [])
        core_fq = "(id:(#{object_ids.join(' OR ')}))"
        core_fq += " AND (#{Solrizer.solr_name('has_model', :symbol)}:#{object_model})" if object_model.present?
        fq_params << core_fq
        available_member_works_filter_query(fq_params: fq_params, object_model: object_model)
      end

      # @api public
      #
      # Works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_member_works_filter_query(fq_params: [], object_model: nil)
        query_solr_with_fq(
          query_builder: works_search_builder, 
          query_params: params[:cq], 
          fq_params: fq_params,
          rows: (rows = rows_param(object_model)), 
          start: start_param(rows)
        )
      end

      def available_media_works_filter_query(fq_params: [], core_fq: [], object_model: nil)
        query_solr_for_media_with_fq(
          query_builder: works_search_builder, 
          query_params: params[:cq], 
          fq_params: fq_params, 
          core_fq: core_fq, 
          rows: (rows = rows_param(object_model)), 
          start: start_param(rows)
        )
      end

      def works_search_builder
        @works_search_builder ||= Morphosource::CollectionMemberSearchBuilder.new(scope: scope, collection_id: collection.id, search_includes_models: :works)
      end

      # @api public
      #
      # Collections which are members of the current collection
      # @return [Blacklight::Solr::Response] {up to 50 solr documents}
      def available_member_subcollections
        query_solr(query_builder: subcollections_search_builder(collection.id), query_params: params_for_subcollections)
      end

      private

      # @api private
      #
      def rows_param(object_model = nil)
        case object_model.to_s
          when "BiologicalSpecimen"
            rows = params[:brows]
          when "CulturalHeritageObject"
            rows = params[:crows]
          else
            rows = params[:rows]
          end
        rows.presence || Hyrax.config.teams_show_work_item_rows
      end

      # @api private
      #
      def start_param(rows = 10)
        page = params[:page].presence || 1
        ((page.to_i - 1) * rows.to_i).to_s
      end

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
      # set up a member search builder for collections only
      # @return [CollectionMemberSearchBuilder] new or existing
      def subcollections_search_builder(collection_id)
        @subcollections_search_builder ||= Morphosource::CollectionMemberSearchBuilder.new(scope: scope, collection_id: collection_id, search_includes_models: :collections)
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

      # @api private
      #
      def assemble_organization_media_query(organization_object_ids)
        " OR (#{Solrizer.solr_name('physical_object_id', :stored_searchable)}:(#{organization_object_ids.join(' OR ')}))"
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
          query_builder.rows = rows
          query_builder.start = start
          repository.search(query_builder.query)
        ensure
          query_builder.merge(q: initial_q)
          query_builder.merge(fq: initial_fq)
          query_builder.rows = initial_rows
          query_builder.start = initial_start
        end
      end

      def query_solr_for_media_with_fq(query_builder:, query_params:, fq_params:, core_fq:, rows: 10, start: 0)
        initial_q = query_builder[:q]
        initial_fq = query_builder[:fq]
        initial_rows = query_builder.rows
        initial_start = query_builder.start
        begin
          query_builder.merge(q: query_params)
          query_builder.merge(fq: prepare_media_query_fq_param(initial_fq, fq_params, core_fq))
          query_builder.rows = rows
          query_builder.start = start
          repository.search(query_builder.query)
        ensure
          query_builder.merge(q: initial_q)
          query_builder.merge(fq: initial_fq)
          query_builder.rows = initial_rows
          query_builder.start = initial_start
        end
      end

      def prepare_media_query_fq_param(initial, new, new_core)
        ((initial.map { |x| x == std_core_fq && new_core.present? ? new_core : x }) + new).uniq
      end

      def std_core_fq
        "#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:#{collection.id}"
      end
    end
  end
end
