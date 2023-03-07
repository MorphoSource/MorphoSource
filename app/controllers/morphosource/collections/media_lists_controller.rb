module Morphosource
  module Collections
    class MediaListsController < Morphosource::CollectionsController

      include Morphosource::Collections::OrderedMediaBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet, :order_media], instance_name: :collection

      before_action :redirect_to_collection_type, only: []

      # temporary restriction so only admins can access media lists and sequential section lists
      before_action :authorize_admin

      class_attribute :collection_type

      self.presenter_class = Morphosource::Collections::MediaListPresenter

      self.collection_type = collection_type

      def query_solr
        if @collection.ordered_media.present?
          response = search_results(params)[0]
          document_list = search_results(full_collection_params(params))[1]
          sorted_document_list = sort_document_list(document_list)
          [response, sorted_document_list]
        else
          (response, document_list) = search_results(params)
        end
      end

      private

        def authorize_admin
          redirect_to root_path and return unless current_user&.admin?
        end

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.media_list_media_path(@curation_concern, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          args.merge!(request.params)
          main_app.media_list_media_facet_path(@collection.id, args)
        end

        def collection_type
          Hyrax::CollectionType.find_by(title: 'Media List')
        end

    end
  end
end
