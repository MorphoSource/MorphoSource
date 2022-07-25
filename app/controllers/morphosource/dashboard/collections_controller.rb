module Morphosource
  module Dashboard
    class CollectionsController < Hyrax::Dashboard::CollectionsController
      include Morphosource::Dashboard::CollectionsControllerBehavior
      include Morphosource::CollectionHelper

      skip_load_and_authorize_resource only: [:edit, :update], instance_name: :collection

      with_themed_layout 'morphosource_dashboard'

      before_action :filter_docs_with_read_access!, only: []
      before_action :load_collection
      before_action :redirect_to_collection_type, only: [:edit, :update]

      self.presenter_class = presenter_class

      self.form_class = Hyrax::Forms::CollectionForm

      def edit
        presenter
        @media_count, @object_count = collection_media
        super
      end

      def update
        update_thumbnail
        super
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

      def update_referer
        return collection_media_path(@collection) if params[:showcase]

        return edit_dashboard_collection_path(@collection) + (params[:referer_anchor] || '') if params[:stay_on_edit]

        dashboard_collection_path(@collection)
      end

      # def remove_members_from_collection
      #   @collection.remove_member_objects(batch)
      # end


       def load_collection
          @curation_concern ||= params[:collection_id].present? ? ::Collection.find(params[:collection_id]) : ::Collection.find(params[:id])
          @collection ||= @curation_concern
          authorize! :edit, @collection
          rescue CanCan::AccessDenied
            redirect_to root_url, alert: 'You are not authorized to access this collection.'
        end


        # def collection_media
        #   Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{@collection.id}")
        # end



       #  def single_item_search_builder
       #   single_item_search_builder_class.new(self).with(params.except(:q, :page))
       # end

       #

       def update_thumbnail
         media = Media.where(id: params[:collection][:representative_id]).first
         @collection.thumbnail_id = media.try(:thumbnail_id)
       end

       # def update_physical_object_index
       #   return if params["batch_document_ids"].blank?
       #
       #   member_ids = params["batch_document_ids"]
       #   member_ids.each do |id|
       #     member = Media.find(id)
       #     object_id = member.physical_object_id
       #     next if object_id.blank?
       #
       #     ActiveFedora::Base.where(id: object_id).first.try(:update_index)
       #   end
       # end
    end
  end
end
