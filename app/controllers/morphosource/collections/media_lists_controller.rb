module Morphosource
  module Collections
    class MediaListsController < Morphosource::CollectionsController

      include Morphosource::Collections::OrderedMediaBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet, :order_media], instance_name: :collection

      before_action :redirect_to_collection_type, only: []

      # temporary restriction so only admins can access media lists and sequential section lists
      # allow show action only
      before_action :authorize_admin, except: [:show, :about, :facet]

      class_attribute :collection_type

      self.presenter_class = Morphosource::Collections::MediaListPresenter

      self.collection_type = collection_type

      def show
        @tab = tab
        # save abilities so we won't have to check multiple times in views.
        @can_edit = current_ability.can? :edit, @collection
        @can_deposit = current_ability.can? :deposit, @collection
        presenter
        (@media_count, @object_ids) = collection_media
        (@response, @document_list) = query_solr

        if params[:view].present?
          if params[:view] == 'false'
            @hide_viewer = true
          elsif @document_list.map(&:id).include?(params[:view])
            @preview_document_id = params[:view]
          else
            redirect_to request.params.except(:view) and return
          end
        end

        if params[:view] == 'false'
          @hide_viewer = true
        end


        publication_settings_nag
        query_collection_counts
        query_collection_members
  
        respond_to do |format|
          format.html { store_preferred_view }
        end
      end

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

      # Load UV media preview via ajax
      def preview
        redirect_to show and return unless has_uv_preview?

        if (
          params[:media_id].present? &&
          Media.where(id: params[:media_id]).count > 0 &&
          doc = SolrDocument.find(params[:media_id])
        )
          @media_presenter = Hyrax::MediaPresenter.new(doc, current_ability)
          @media_presenter.get_showcase_data
        end

        respond_to do |format|
          format.js { render layout: false }
          format.html { render 'show'}
        end
      end

      private

        def authorize_admin
          redirect_to root_path and return unless current_user&.admin?
        end

        def load_media_preview_presenter(id)
          if (
            has_uv_preview? && 
            @document_list&.first.present? && 
            (doc = SolrDocument.find(@document_list&.first&.id))
          )
            @media_presenter = Hyrax::MediaPresenter.new(doc, current_ability)
            @media_presenter.get_showcase_data
          end
        end

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.media_list_path(@curation_concern, *args)
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

        # unlike most collections, media lists have uv preview pane
        def has_uv_preview?
          true
        end
        helper_method :has_uv_preview?

    end
  end
end
