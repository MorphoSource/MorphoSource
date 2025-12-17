module Morphosource
  module Collections
    class MediaListsController < Morphosource::CollectionsController

      include Morphosource::Collections::OrderedMediaBehavior

      skip_load_and_authorize_resource only: [
        :about,
        :facet,
        :media_download_counts_with_intersections_facet,
        :media_downloads,
        :media_export_with_intersections_facet,
        :media_requests,
        :order_media,
        :preview,
        :show
      ], instance_name: :media_list

      before_action :redirect_to_collection_type, only: []

      # media list managers do not necessarily have edit access to media in the list, so they shouldn't be able to view information about other users' downloads/requests for list media.
      before_action :authorize_admin, only: [:media_downloads, :media_requests]

      class_attribute :collection_type

      self.presenter_class = Morphosource::Collections::MediaListPresenter

      self.collection_type = collection_type

      def show
        @tab = tab
        # save abilities so we won't have to check multiple times in views.
        @can_edit = current_ability.can? :edit, @collection
        @can_deposit = current_ability.can? :deposit, @collection
        presenter
        @object_ids = collection_object_ids
        (@response, @document_list) = query_solr

        if params[:preview].present?
          if params[:preview] == 'false'
            @hide_viewer = true
          elsif @document_list.map(&:id).include?(params[:preview])
            @preview_document_id = params[:preview]
          else
            redirect_to request.params.except(:preview) and return
          end
        end

        if params[:preview] == 'false'
          @hide_viewer = true
        end

        publication_settings_nag
        query_collection_counts
        query_collection_members

        respond_to do |format|
          format.html { store_preferred_view }
        end
      end

      # TODO5: Maybe this should be refactored to use Hyrax 5's member_works approach
      def query_solr
        # remove sort param if sorting by order - will break solr query
        @ordered_sort = params.delete("sort")if params["sort"]&.include? "order"
        if @collection.ordered_media.present?
          response = blacklight_config.repository.search(search_builder.with(params))
          document_list = blacklight_config.repository.search(search_builder.with(full_collection_params(params)))
          sorted_document_list = sort_document_list(document_list.documents)
          # replace so ordered sort asc/desc ui toggle works correctly
          params["sort"] = @ordered_sort if @ordered_sort.present?
          [response, sorted_document_list]
        else
          response = blacklight_config.repository.search(search_builder.with(params))
          [response, response.documents]
        end
      end

      # Load UV media preview via ajax
      def preview
        redirect_to show and return unless has_uv_preview?

        if (
          params[:media_id].present? &&
          Media.where(id: params[:media_id]).count > 0 &&
          doc = SolrDocument.find(params[:media_id])
        )
          @media_presenter = Hyrax::MediaPresenter.new(doc, current_ability)
        end

        respond_to do |format|
          format.js { render layout: false }
          format.html { render 'show'}
        end
      end

      private

        def load_media_preview_presenter(id)
          if (
            has_uv_preview? &&
            @document_list&.first.present? &&
            (doc = SolrDocument.find(@document_list&.first&.id))
          )
            @media_presenter = Hyrax::MediaPresenter.new(doc, current_ability)
          end
        end

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.media_list_path(@collection, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          request.params.delete("id")
          args.merge!(request.params)
          main_app.media_list_media_facet_path(@collection.id, args)
        end


        def collection_type
          Hyrax::CollectionType.find_by(title: 'Media List')
        end

        # unlike most collections, media lists have uv preview pane
        def has_uv_preview?
          true
        end
        helper_method :has_uv_preview?

    end
  end
end
