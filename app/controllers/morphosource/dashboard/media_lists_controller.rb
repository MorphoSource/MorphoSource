module Morphosource
  module Dashboard
    ## Shows a list of all collections to the admins
    class MediaListsController < Hyrax::Dashboard::CollectionsController

      self.presenter_class = Morphosource::MediaListPresenter

      self.form_class = Morphosource::Forms::MediaListForm

      def new
        @collection = MediaList.new
        # Coming from the UI, a collection type id should always be present.  Coming from the API, if a collection type id is not specified,
        # use the default collection type (provides backward compatibility with versions < Hyrax 2.1.0)
        # collection_type_id = params[:collection_type_id].presence || default_collection_type.id
        # @collection.collection_type_gid = CollectionType.find(collection_type_id).gid
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t('.header', type_title: @collection.collection_type.title), request.path
        @collection.apply_depositor_metadata(current_user.user_key)
        form
      end

      def create
        # Manual load and authorize necessary because Cancan will pass in all
        # form attributes. When `permissions_attributes` are present the
        # collection is saved without a value for `has_model.`
        @collection = ::MediaList.new
        authorize! :create, @collection

        @collection.attributes = collection_params.except(:members, :parent_id, :collection_type_gid)
        @collection.apply_depositor_metadata(current_user.user_key)
        add_members_to_collection unless batch.empty?
        @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
        byebug
        if @collection.save
          after_create
        else
          after_create_error
        end
      end

      def collection_params
          @participants = extract_old_style_permission_attributes(params[:media_list])
          form_class.model_attributes(params[:media_list])
      end

      def after_create
        form
        set_default_permissions
        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.

        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to edit_media_list_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success') }
          format.json { render json: @collection, status: :created, location: dashboard_media_list_path(@collection) }
        end
      end

      def edit
        byebug
        form
      end


      # def default_collection_type
      #   MediaList.collection_type
      # end

    end
  end
end
