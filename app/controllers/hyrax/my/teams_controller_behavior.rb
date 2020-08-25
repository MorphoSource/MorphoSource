# Cloned from CollectionsControllerBehavior to set TeamPresenter
module Hyrax
  module My
    module TeamsControllerBehavior
      extend ActiveSupport::Concern
      include Blacklight::AccessControls::Catalog
      include Blacklight::Base
#      include MorphosourceHelper
#      include Morphosource::MediaWorksHelper

      included do
        # include the display_trophy_link view helper method
        helper Hyrax::TrophyHelper

        # This is needed as of BL 3.7
        copy_blacklight_config_from(::CatalogController)

        class_attribute :presenter_class,
#                        :form_class,
#                        :single_item_search_builder_class,
                        :teams_service_class,
                        :information_service_class

        #self.presenter_class = Hyrax::MediaWorksPresenter

        # The search builder to find the collection
#        self.single_item_search_builder_class = SingleCollectionSearchBuilder
        # The search builder to find the collections' members
        self.teams_service_class = Morphosource::Collections::TeamsService
        self.information_service_class = Morphosource::Collections::TeamsInformationService
      end

      def collection
        action_name == 'show' ? @presenter : @collection
      end

      private

        #def presenter
        #  @presenter ||= begin
        #    presenter_class.new(current_user, current_ability)
        #  end
        #end

        #def presenter
        #  @presenter ||= begin
        #    # Query Solr for the collection.
        #    # run the solr query to find the collection members
        #    response = repository.search(single_item_search_builder.query)
        #    curation_concern = response.documents.first
        #    raise CanCan::AccessDenied unless curation_concern
        #    presenter_class.new(curation_concern, current_ability)
        #  end
        #end

        # Instantiates the search builder that builds a query for a single item
        # this is useful in the show view.
#        def single_item_search_builder
#          # setting higher collection limit   
#          # params.merge!({ 'rows' => '999999', 'page' => '1' })
#          single_item_search_builder_class.new(self).with(params.except(:q, :page))
#        end
#
#        def collection_params
#          form_class.model_attributes(params[:collection])
#        end
#
#        # Include 'catalog' and 'hyrax/base' in the search path for views, while prefering
#        # our local paths. Thus we are unable to just override `self.local_prefixes`
#        def _prefixes
#          @_prefixes ||= super + ['catalog', 'hyrax/base']
#        end


#        def query_collection_members
#          member_works
#          prepare_docs_and_filters_for_media
#        end

        def teams_service 
           teams_service_class.new(scope: self, user: current_user, params: params_for_query)
        end

        def teams_information_service
          @teams_information_service ||= information_service_class.new(current_user, @collection_list_type_id) 
        end

        def paginated_item_list
          # Uses kaminari to paginate an array to avoid need for solr documents for items here
          Kaminari.paginate_array(@document_list, total_count: @document_list.size).page(current_page).per(rows_from_params)
        end

        def total_items
          @document_list.size
        end

        def current_page
          page = request.params[:page].nil? ? 1 : request.params[:page].to_i
          page > total_pages ? total_pages : page
        end

        # @return [Integer] total number of pages of viewable items
        def total_pages
          (total_items.to_f / rows_from_params.to_f).ceil
        end

        def rows_from_params
          request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:rows].to_i
        end

#        def member_works
#          @response = collection_member_service.all_member_media(
#            @collection_organization_object_ids, media_filter_params)
#          @member_docs = @response.documents
#          @members_count = @response.total
#          @media_member_count = @members_count
#        end

#        def subcollection_member_service(subcollection)
#          teams_service_class.new(scope: self, user: current_user, collection: subcollection, params: params_for_query)
#        end



#        def collection_object
#          action_name == 'show' ? Collection.find(collection.id) : collection
#        end
#
#
#        # You can override this method if you need to provide additional inputs to the search
#        # builder. For example:
#        #   search_field: 'all_fields'
#        # @return <Hash> the inputs required for the collection member query service
#        def params_for_query
#          #params.merge(q: params[:cq])
#
#          # setting higher collection limit for paginating the array       
#          params.merge(q: params[:q]).merge({ 'rows' => '999999', 'page' => '1' })
#        end
    end
  end
end