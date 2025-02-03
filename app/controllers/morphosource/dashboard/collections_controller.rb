module Morphosource
  module Dashboard
    class CollectionsController < Hyrax::Dashboard::CollectionsController
      include Morphosource::Dashboard::CollectionsControllerBehavior

      skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :projects, :organization, :create], instance_name: :collection

      with_themed_layout 'morphosource_dashboard'

      before_action :filter_docs_with_read_access!, only: []
      before_action :load_collection, except: [:create]
      before_action :redirect_to_collection_type, only: [:edit, :update, :new, :create]
      before_action :authorize_contributor, only: [:new]

      include Morphosource::Breadcrumbs::Collections

      self.presenter_class = presenter_class

      self.form_class = Hyrax::Forms::CollectionForm

      helper_method :search_action_for_dashboard

      # override to create new MediaList/Sequential Section List/Organization etc. instead of Collection
      def create
        # Manual load and authorize necessary because Cancan will pass in all
        # form attributes. When `permissions_attributes` are present the
        # collection is saved without a value for `has_model.`
        @collection = collection_class.new
        authorize! :create, @collection
        # Coming from the UI, a collection type gid should always be present.  Coming from the API, if a collection type gid is not specified,
        # use the default collection type (provides backward compatibility with versions < Hyrax 2.1.0)
        @collection.collection_type_gid = params[:collection_type_gid].presence || default_collection_type.to_global_id
        @collection.attributes = collection_params.except(:members, :parent_id, :collection_type_gid)
        @collection.depositor = current_user.user_key
        add_members_to_collection unless batch.empty?
        @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless Hyrax::CollectionType.for(collection: @collection).discoverable?
        if @collection.save
          after_create
        else
          after_create_error
        end
      end

      def edit
        @tab = :details
        presenter
        super
      end

      def update
        update_thumbnail
        super
      end

      def after_update
        respond_to do |format|
          format.html {
            redirect_to permissions_path, notice: "Remote file submission settings updated" and return if params[:update_remote_file_submission_settings]

            redirect_to helpers.collection_media_path(@collection), notice: t('hyrax.dashboard.my.action.collection_update_success')
          }
          format.json { render json: @collection, status: :updated, location: helpers.collection_media_path(@collection) }
        end
      end
      # Hyrax 3.6.0 deprecated after_update in favor of after_update_response
      alias after_update_response after_update

      # Simple end-point to remove single collection member
      def remove_member
        authorize! :update, @collection
        @collection.remove_member_objects([params[:member_id]])
        after_update
      end

      def batch_remove_members_ajax
        remove_ids = params["remove_ids"]
        if remove_ids.present? && remove_ids.is_a?(Array) && remove_ids.all? { |id| id.is_a?(String) && id.match?(/^\d+$/) }
          RemoveCollectionMembersJob.perform_later(@collection.id, remove_ids)
          respond_to do |format|
            format.json { render json: { status: 'success' }, status: :ok }
          end
        else
          respond_to do |format|
            format.json { render json: { status: 'fail', error: 'Nothing to remove'  }, status: :ok }
          end
        end
      end

      def process_member_changes
        case member_params
        when 'add' then add_members_to_collection
        when 'remove' then remove_members_from_collection
        when 'move' then move_members_between_collections
        end
      end

      def add_members_to_collection(collection = nil)
        collection ||= @collection
        collection.add_member_objects batch
      end

      def remove_members_from_collection
        @collection.remove_member_objects(batch)
      end

      def move_members_between_collections
        destination_collection = ::Collection.find(params[:destination_collection_id])
        remove_members_from_collection
        add_members_to_collection(destination_collection)
        if destination_collection.save
          flash[:notice] = "Successfully moved #{batch.count} files to #{destination_collection.title} Collection."
        else
          flash[:error] = "An error occured. Files were not moved to #{destination_collection.title} Collection."
        end
      end

      def members
        @tab = :members
        presenter
        form
        render 'edit'
      end

      def after_destroy(_id)
        # leaving id to avoid changing the method's parameters prior to release
        respond_to do |format|
          format.js {render :js => "location.reload()"}
          format.html do
            redirect_to main_app.send("my_#{@collection.collection_type.machine_id.pluralize}_path")
          end
          format.json { head :no_content, location: '/dashboard/my/collections' }
        end
      end

      def after_create
        set_default_permissions
        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.
        link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to helpers.collection_edit_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success') }
          format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
        end
      end

      def set_default_permissions
        set_morphosource_permissions
      end

      private

      def authorize_admin
        redirect_to root_path and return unless current_user.admin?
      end

      # only contributors can access the dashboard new collection page
      def authorize_contributor
        authorize! :create, ::Collection
      rescue CanCan::AccessDenied
        redirect_to root_url, alert: 'You are not authorized to access this page.'
      end

      def update_referer
        return helpers.collection_media_path(@collection) if params[:showcase]

        return edit_dashboard_collection_path(@collection) + (params[:referer_anchor] || '') if params[:stay_on_edit]

        dashboard_collection_path(@collection)
      end

      def set_morphosource_permissions
        @collection.create_collection_groups
        @collection.copy_parent_membership(params[:parent_id]) unless params[:parent_id].nil?
        Morphosource::Collections::PermissionsCreateService.create_default(collection: @collection)
      end

      def load_collection
        if params[:id] || params[:collection_id]
          @curation_concern = params[:collection_id].present? ? ::Collection.find(params[:collection_id]) : ::Collection.find(params[:id])
          authorize! :edit, @curation_concern
        else
          @curation_concern ||= collection_class.new
        end
        @collection = @curation_concern
        rescue CanCan::AccessDenied
        redirect_to root_url, alert: 'You are not authorized to access this collection.'
      end

      def collection_class
        Collection
      end

      def default_collection_type_gid
        default_collection_type.to_global_id
      end

      def update_thumbnail
        media = Media.where(id: thumbnail_params).first
        @collection.thumbnail_id = media.try(:thumbnail_id)
      end

      def permissions_path
        team_organization_path(@collection)
      end
    end
  end
end
