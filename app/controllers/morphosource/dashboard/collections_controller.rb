module Morphosource
  module Dashboard
    class CollectionsController < Hyrax::Dashboard::CollectionsController
      include Morphosource::CollectionHelper
      # helper_method :hidden_params_for_filters, :hidden_params_for_pagination, :publication_status_label,
      #   :media_type_label, :filter_params, :ms_collection_view_link, :source_label, :dashboard_bso_tab_url, :dashboard_cho_tab_url, :origin_label, :filter_projects, :ms_collection_view_link, :ms_collection_view_link_qs

        with_themed_layout 'morphosource_dashboard'

        before_action :filter_docs_with_read_access!, except: [:show, :update, :edit]
        before_action :filter_docs_with_edit_access!, only: [:update]

        # delete?
        class_attribute :presenter_class,
                        :form_class,
                        :single_item_search_builder_class,
                        :membership_service_class,
                        :information_service_class

      self.presenter_class = Hyrax::TeamPresenter

      # delete?
      self.information_service_class = Morphosource::Collections::CollectionInformationService

      # delete?
      load_and_authorize_resource except: [:index, :specimens, :chos, :create], instance_name: :collection

      def new
        byebug
        super
      end

      # TODO route for show
      def show
        # if the current user has edit permission, redirect to edit
        if current_user and can? :edit, @collection
          tab = request.params[:tab]
          edit_path = edit_dashboard_collection_url + '&' + request.params.slice!(:action, :id, :controller, :locale, :tab).to_query
          edit_path += '#' + tab if tab.present?
          redirect_to edit_path
        elsif current_user and can? :read, @collection
          # if the user only has read access, redirect to the pubiic view page
          if collection.project?
            redirect_to main_app.project_path
          elsif collection.team?
            redirect_to main_app.team_path
          else
            redirect_to root_url
          end
        else
          # run the presenter and other methods (same as the team_presenter methods) necessary for
          # displaying teams and project show page content
          presenter
          query_collection_information
          query_collection_members
          form
        end
      end

      def edit
        byebug
        # this is called when user save the collection form on the show action
        # if needed, redirect show to edit if user has permission to save
        presenter
        query_collection_information
        query_collection_members
        form
      end

      def specimens
        presenter
        @collection ||= presenter.collection
        query_collection_information
        query_collection_members_for_po
        render partial: "hyrax/teams/tab_bso"
      end

      def chos
        presenter
        @collection ||= presenter.collection
        query_collection_information
        query_collection_members_for_po
        render partial: "hyrax/teams/tab_cho"
      end

      # todo: need to add logic to keep the old hyrax view if still needed
      def show_hyrax
        if request.parameters['hyrax'].present?
          # todo: keep the old show page in case needed.  this param check can be removed later
          if @collection.collection_type.brandable?
            banner_info = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "banner")
            @banner_file = "/" + banner_info.first.local_path.split("/")[-4..-1].join("/") unless banner_info.empty?
          end
          self.presenter_class = Hyrax::CollectionPresenter
          presenter
          query_collection_members
        else
          # redirect dashboard page to edit page when ready
          redirect_to '/dashboard/collections/' + @collection.id + '/edit'
        end
      end

      def after_create
        form
        set_default_permissions
        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.
        link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
        respond_to do |format|
          ActiveFedora::SolrService.commit
          format.html { redirect_to hyrax.edit_dashboard_collection_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success') }
          format.json { render json: @collection, status: :created, location: hyrax.dashboard_collection_path(@collection) }
        end
      end

      def update
        unless params[:update_collection].nil?
          process_banner_input
          process_logo_input
        end
        update_thumbnail
        process_member_changes
        @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
        # we don't have to reindex the full graph when updating collection
        @collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
        if @collection.update(collection_params.except(:members))
          after_update
        else
          after_update_error
        end
      end

      def after_destroy(_id)
        # leaving id to avoid changing the method's parameters prior to release
        respond_to do |format|
          format.js {render :js => "location.reload()"}
          format.html do
            redirect_to request.referrer
          end
          format.json { head :no_content, location: '/dashboard/my/collections' }
        end
      end

      def after_destroy_error(id)
        respond_to do |format|
          format.html do
            flash[:notice] = t('hyrax.dashboard.my.action.collection_delete_fail')
            render :edit, status: :unprocessable_entity
          end
          format.json { render json: { id: id }, status: :unprocessable_entity, location: dashboard_collection_path(@collection) }
        end
      end

      def remove_members_from_collection
        @collection.remove_member_objects(batch)
      end

      def query_collection_members
        member_works # 15.7, 9.5, 53.0, 97.2 ms
        member_subcollections if collection.collection_type.nestable? # 7 - 21 ms
        # parent collection should not be needed.  remove below later
        #parent_collections if collection.collection_type.nestable? && action_name == 'show' # 7 - 14 ms for project
        prepare_docs_and_filters_for_media(@collection)
      end

      def query_collection_members_for_po
        member_works_objects
        member_subcollections if collection.collection_type.nestable? # 7 - 21 ms
        prepare_docs_and_filters_for_po(@collection)
      end

      # Instantiate the membership query service
      def collection_member_service
        @collection_member_service ||= membership_service_class.new(scope: self, collection: collection, params: params_for_query)
      end

      # Instantiate the information query service
      def collection_information_service
        @collection_information_service ||= information_service_class.new(scope: self, collection_id: collection.id)
      end

      def subcollection_media_service(subcollection)
        membership_service_class.new(scope: self, collection: subcollection, params: params_for_query)
      end

      def member_works
        @response = collection_member_service.all_member_media(
          @collection_organization_object_ids, media_filter_params)
        @member_docs = @response.documents
        @members_count = @response.total
      end

      def member_works_objects
        all_object_ids = @collection_object_ids + @collection_organization_object_ids

        if all_object_ids.present?
          @bso_response = collection_member_service.all_member_media_objects(all_object_ids, BiologicalSpecimen, bso_filter_params)
          @bso_member_docs = @bso_response.documents
          @bso_member_count = @bso_response.total

          @cho_response = collection_member_service.all_member_media_objects(all_object_ids, CulturalHeritageObject, cho_filter_params)
          @cho_member_docs = @cho_response.documents
          @cho_member_count = @cho_response.total

          if !@bso_member_count.present? && @cho_member_count.present?
            @response = @cho_response
          else
            @response = @bso_response
          end
        else
          @bso_response = nil
          @bso_member_docs = []
          @bso_member_count = 0
          @cho_response = nil
          @cho_member_docs = []
          @cho_member_count = 0
          @response = nil
        end
      end

      def set_default_permissions
        if @collection.type_assigns_groups?
          set_morphosource_permissions
        else
          additional_grants = @participants # Grants converted from older versions (< Hyrax 2.1.0) where share was edit or read access instead of managers, depositors, and viewers
          Hyrax::Collections::PermissionsCreateService.create_default(collection: @collection, creating_user: current_user, grants: additional_grants)
        end
      end

      def set_morphosource_permissions
        @collection.create_collection_groups
        @collection.copy_parent_membership(params[:parent_id]) unless params[:parent_id].nil?
        Morphosource::Collections::PermissionsCreateService.create_default(collection: @collection)
      end

      def update_thumbnail
        media = Media.where(id: params[:collection][:representative_id]).first
        @collection.thumbnail_id = media.try(:thumbnail_id)
      end
    end
  end
end
