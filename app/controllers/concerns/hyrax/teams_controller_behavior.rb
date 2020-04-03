# Cloned from CollectionsControllerBehavior to set TeamPresenter
module Hyrax
  module TeamsControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base
    include MorphosourceHelper

    included do
      # include the display_trophy_link view helper method
      helper Hyrax::TrophyHelper

      # This is needed as of BL 3.7
      copy_blacklight_config_from(::CatalogController)

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :membership_service_class

      self.presenter_class = Hyrax::TeamPresenter

      # The search builder to find the collection
      self.single_item_search_builder_class = SingleCollectionSearchBuilder
      # The search builder to find the collections' members
      self.membership_service_class = Collections::CollectionMemberService
    end

    def show
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      presenter
      query_collection_members
    end

    def collection
      action_name == 'show' ? @presenter : @collection
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
        member_works
        member_subcollections if collection.collection_type.nestable?
        parent_collections if collection.collection_type.nestable? && action_name == 'show'
      end

      # Instantiate the membership query service
      def collection_member_service
        @collection_member_service ||= membership_service_class.new(scope: self, collection: collection, params: params_for_query)
      end

      def member_works
        @response = collection_member_service.available_member_works
        @member_docs = @response.documents
        @members_count = @response.total
 
        @media_member_docs, @bso_member_docs, @bso_extras, 
          @cho_member_docs, @cho_extras = get_medias_and_objects(@member_docs)
        @bso_member_docs = dedup(@bso_member_docs) if @bso_member_docs.present?
        @cho_member_docs = dedup(@cho_member_docs) if @cho_member_docs.present?
        @media_member_count = @media_member_docs.length
        @bso_member_count = @bso_member_docs&.length || 0
        @cho_member_count = @cho_member_docs&.length || 0
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

      def get_medias_and_objects(docs)
        media_documents = []
        bso_documents = []
        cho_documents = []
        bso_extras = []
        cho_extras = []

        docs.each do |doc|
          work = ::ActiveFedora::Base.find(doc.id)
          if work.class == Media
            media_documents << doc
            # get BSO and CHO
            bso_doc, bso_extra, cho_doc, cho_extra = physical_object_solr_from_media(doc.id)
            if bso_doc.present?
              unless bso_documents.any? {|h| h['id'] == bso_doc.id}
                # check if the ID already exists before adding
                bso_documents << bso_doc
                bso_extras << bso_extra
              end
            end
            if cho_doc.present?
              unless cho_documents.any? {|h| h['id'] == cho_doc.id}
                cho_documents << cho_doc 
                cho_extras << cho_extra
              end
            end
          end
        end 
        return media_documents.compact, bso_documents.compact, bso_extras,
          cho_documents.compact, cho_extras
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
        params.merge(q: params[:cq])
      end
  end
end