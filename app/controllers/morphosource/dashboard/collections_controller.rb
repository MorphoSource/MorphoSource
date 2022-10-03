module Morphosource
  module Dashboard
    class CollectionsController < Hyrax::Dashboard::CollectionsController
      include Morphosource::Dashboard::CollectionsControllerBehavior
      include Morphosource::CollectionHelper

      skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :projects, :organization, :create], instance_name: :collection

      with_themed_layout 'morphosource_dashboard'

      before_action :filter_docs_with_read_access!, only: []
      before_action :build_breadcrumbs, only: []
      before_action :load_collection, except: [:create]
      before_action :redirect_to_collection_type, only: [:edit, :update, :new, :create]

      self.presenter_class = presenter_class

      self.form_class = Hyrax::Forms::CollectionForm

      def edit
        @tab = :details
        presenter
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t('.header', type_title: @collection.collection_type.title), request.path
        super
      end

      def update
        update_thumbnail
        super
      end

      def after_update
        respond_to do |format|
          format.html { redirect_to collection_media_path(@collection), notice: t('hyrax.dashboard.my.action.collection_update_success') }
          format.json { render json: @collection, status: :updated, location: collection_media_path(@collection) }
        end
      end

      def process_member_changes
          case params[:collection][:members]
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
            if @collection.team?
              redirect_to main_app.my_teams_path
            else
              redirect_to main_app.my_projects_path
            end
          end
          format.json { head :no_content, location: '/dashboard/my/collections' }
        end
      end

      def create
        unless current_user.can?(:create_any, Collection)
          redirect_to root_url, alert: 'You are not authorized to create this collection.' and return
        end
        super
      end

      def after_create
        set_default_permissions
        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.
        link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to collection_edit_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success') }
          format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
        end
      end

      def set_default_permissions
        set_morphosource_permissions
      end

      private

      def update_referer
        return collection_media_path(@collection) if params[:showcase]

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
          @curation_concern ||= params[:collection_id].present? ? ::Collection.find(params[:collection_id]) : ::Collection.find(params[:id])
          authorize! :edit, @curation_concern
        else
          @curation_concern ||= Collection.new
        end
        @collection ||= @curation_concern
        rescue CanCan::AccessDenied
        redirect_to root_url, alert: 'You are not authorized to access this collection.'
      end

       def update_thumbnail
         media = Media.where(id: params[:collection][:representative_id]).first
         @collection.thumbnail_id = media.try(:thumbnail_id)
       end

    end
  end
end
