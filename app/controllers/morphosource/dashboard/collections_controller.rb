module Morphosource
  module Dashboard
    class CollectionsController < Hyrax::Dashboard::CollectionsController

      with_themed_layout 'morphosource_dashboard'

      self.presenter_class = Hyrax::TeamPresenter

      def edit
        presenter
        @media_count = collection_media.count
        super
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

      private

        def collection_media
          Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{@collection.id}")
        end
    end
  end
end
