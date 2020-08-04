# Cloned from CollectionsControllerBehavior to set TeamPresenter
module Hyrax
  module TeamsControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base
    include MorphosourceHelper
    include Morphosource::CollectionHelper

    included do
      # include the display_trophy_link view helper method
      helper Hyrax::TrophyHelper

      # This is needed as of BL 3.7
      copy_blacklight_config_from(::CatalogController)

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :membership_service_class,
                      :information_service_class

      self.presenter_class = Hyrax::TeamPresenter

      # The search builder to find the collection
      self.single_item_search_builder_class = SingleCollectionSearchBuilder
      # The search builder to find the collections' members
      self.membership_service_class = Morphosource::Collections::CollectionMemberService
      self.information_service_class = Morphosource::Collections::CollectionInformationService
    end

    def show
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      presenter
      query_collection_information
      query_collection_members
    end

    def specimens
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      presenter
      query_collection_information
      query_collection_members_for_po
      render partial: "tab_bso"
    end

    def collection
      action_name == 'show' || action_name == 'specimens' ? @presenter : @collection
    end

    private

      def presenter
        @presenter ||= begin
          # Query Solr for the collection.
          # run the solr query to find the collection members
          response = repository.search(single_item_search_builder.query)
          curation_concern = response.documents.first
          raise CanCan::AccessDenied unless curation_concern
          presenter_class.new(curation_concern, current_ability)
        end
      end

      # Instantiates the search builder that builds a query for a single item
      # this is useful in the show view.
      def single_item_search_builder
        # setting higher collection limit   
        # params.merge!({ 'rows' => '999999', 'page' => '1' })
        single_item_search_builder_class.new(self).with(params.except(:q, :page))
      end

      def collection_params
        form_class.model_attributes(params[:collection])
      end

      # Include 'catalog' and 'hyrax/base' in the search path for views, while prefering
      # our local paths. Thus we are unable to just override `self.local_prefixes`
      def _prefixes
        @_prefixes ||= super + ['catalog', 'hyrax/base']
      end

      def query_collection_members
        member_works # 15.7, 9.5, 53.0, 97.2 ms
        member_subcollections if collection.collection_type.nestable? # 7 - 21 ms
        # parent collection should not be needed.  remove below later
        #parent_collections if collection.collection_type.nestable? && action_name == 'show' # 7 - 14 ms for project
        prepare_docs_and_filters_for_media(collection)
      end

      def query_collection_members_for_po
        member_works_objects 
        member_subcollections if collection.collection_type.nestable? # 7 - 21 ms
        prepare_docs_and_filters_for_po(collection)
      end

      # Instantiate the membership query service
      def collection_member_service 
         membership_service_class.new(scope: self, collection: collection, params: params_for_query)
      end

      # Instantiate the information query service
      def collection_information_service
        @collection_information_service ||= information_service_class.new(collection.id)
      end

      def subcollection_media_service(subcollection)
        membership_service_class.new(scope: self, collection: subcollection, params: params_for_query)
      end

      def member_works # 24ms
        @response = collection_member_service.all_member_media(@collection_organization_object_ids)
        @member_docs = @response.documents
        @members_count = @response.total
      end

      def member_works_objects
        all_object_ids = @collection_object_ids + @collection_organization_object_ids

        @bso_response = collection_member_service.all_member_media_objects(all_object_ids, BiologicalSpecimen)
        @bso_member_docs = @bso_response.documents
        @bso_member_count = @bso_response.total

        @cho_response = collection_member_service.all_member_media_objects(all_object_ids, CulturalHeritageObject)
        @cho_member_docs = @bso_response.documents
        @cho_member_count = @bso_response.total

        if !@bso_member_count.present? && @cho_member_count.present?
          @response = @cho_response
        else
          @response = @bso_response
        end
      end

      # media pagination methods
      def paginated_media_item_list
        # Uses kaminari to paginate an array to avoid need for solr documents for items here
        Kaminari.paginate_array(@media_member_docs, total_count: @media_member_docs.size).page(media_current_page).per(rows_from_params)
      end

      def media_total_items
        @media_member_count
      end

      def media_current_page
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        page > media_total_pages ? media_total_pages : page
      end

      # @return [Integer] total number of pages of viewable items
      def media_total_pages
        (media_total_items.to_f / rows_from_params.to_f).ceil
      end

      def rows_from_params
        request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:rows].to_i
      end

      # bso pagination methods
      def paginated_bso_item_list
        Kaminari.paginate_array(@bso_member_docs, total_count: @bso_member_docs.size).page(bso_current_page).per(bso_rows_from_params)
      end

      def bso_total_items
        @bso_member_count
      end

      def bso_current_page
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        page > bso_total_pages ? bso_total_pages : page
      end

      def bso_total_pages
        (bso_total_items.to_f / bso_rows_from_params.to_f).ceil
      end

      def bso_rows_from_params
        request.params[:brows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:brows].to_i
      end

      # cho pagination methods
      def paginated_cho_item_list
        Kaminari.paginate_array(@cho_member_docs, total_count: @cho_member_docs.size).page(cho_current_page).per(cho_rows_from_params)
      end

      def cho_total_items
        @cho_member_count
      end

      def cho_current_page
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        page > cho_total_pages ? cho_total_pages : page
      end

      def cho_total_pages
        (cho_total_items.to_f / cho_rows_from_params.to_f).ceil
      end

      def cho_rows_from_params
        request.params[:crows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:crows].to_i
      end

      def dedup(docs) 
        unique_docs = [] 
        unique_ids = []
        docs.each do |doc|
          unless unique_ids.include? doc.id
            unique_ids << doc.id
            unique_docs << doc
          end
        end
        return unique_docs
      end

      def parent_collections
        page = params[:parent_collection_page].to_i
        query = Hyrax::Collections::NestedCollectionQueryService
        collection.parent_collections = query.parent_collections(child: collection_object, scope: self, page: page)
      end

      def collection_object
        action_name == 'show' ? Collection.find(collection.id) : collection
      end

      def member_subcollections
        results = collection_member_service.available_member_subcollections
        @subcollection_solr_response = results
        @subcollection_docs = results.documents
        @subcollection_count = @presenter.subcollection_count = results.total
      end

      # You can override this method if you need to provide additional inputs to the search
      # builder. For example:
      #   search_field: 'all_fields'
      # @return <Hash> the inputs required for the collection member query service
      def params_for_query
        #params.merge(q: params[:cq])

        # setting higher collection limit for paginating the array       
        params.merge(q: params[:cq]).merge({ 'rows' => '999999', 'page' => '1' })
      end
  end
end