# frozen_string_literal: true
module Morphosource
  module Collections
    # Responsible for retrieving collection members
    class TeamsService 
      attr_reader :scope, :params
      delegate :repository, to: :scope
      
      def initialize(scope:, user:, params:)
        @scope = scope
        @user = user
        @params = params
      end

      def all_collections_by_type(collection_type_id, fq_params = [])
#        collection_ids = []
#        subcoll_fq = ""
#        collections.each do |collection_doc|
#          collection_ids << collection_doc.id
#          collection = Collection.find(collection_doc.id)
#          subcoll_fq += assemble_multiple_collection_query_for(collection) if collection.collection_type.nestable?
#        end
#        core_fq = assemble_user_media_query
#        core_fq += " OR (#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:(#{collection_ids.join(' OR ')}))" if collection_ids.length > 0
#        core_fq += subcoll_fq if subcoll_fq.present?
#        core_fq += assemble_organization_media_query(organization_object_ids) if organization_object_ids.present? 
#        fq_params << core_fq
        fq_params << "#{Solrizer.solr_name('has_model', :symbol)}:#{Collection}"
        fq_params << "(#{Solrizer.solr_name('collection_type_gid', :symbol)}:\"gid://morpho-source-sf/hyrax-collectiontype/#{collection_type_id}\")"
#byebug

        response = available_collections_filter_query(fq_params: fq_params)
        return response
      end

      # @api public
      #
      # Works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_collections_filter_query(fq_params: [])
        query_solr_with_fq(query_builder: ms_collections_search_builder, query_params: params[:q], fq_params: fq_params)
      end

      private

#      def assemble_multiple_collection_query_for(coll)
#        subcollection_ids = available_member_subcollections(coll).documents.map { |s| s['id'] }
#        if subcollection_ids.present?
#          " OR (#{Solrizer.solr_name('member_of_collection_ids', :symbol)}:(#{subcollection_ids.join(' OR ')}))"
#        else
#          ""
#        end
#      end


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


              def search_builder_class
                if page_is_project?
                  Morphosource::My::MsProjectsSearchBuilder
                elsif page_is_team?
                  Morphosource::My::MsTeamsSearchBuilder
                else
                  Morphosource::My::MsCollectionsSearchBuilder
                end
              end


      # from app/services/hyrax/collections/collection_member_service.rb

        # @api private
        #
        # set up a member search builder for works only
        # @return [CollectionMemberSearchBuilder] new or existing
        #def works_search_builder
        #  @works_search_builder ||= Hyrax::CollectionSetMemberSearchBuilder.new(scope: scope, collections: collections, search_includes_models: #:works)
        #end

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