module Morphosource
  module Dashboard
    module Collections
      class MediaListsController < Morphosource::Dashboard::CollectionsController
        skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create], instance_name: :media_list

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection

        # temporary restriction so only admins can access media lists and sequential section lists
        before_action :authorize_admin

        self.presenter_class = Morphosource::Collections::MediaListPresenter

        self.form_class = Morphosource::Forms::Collections::MediaListForm

        # override to create new MediaList instead of Collection
        def create
          # Manual load and authorize necessary because Cancan will pass in all
          # form attributes. When `permissions_attributes` are present the
          # collection is saved without a value for `has_model.`
          @collection = collection_class.new
          authorize! :create, @collection
          # Coming from the UI, a collection type gid should always be present.  Coming from the API, if a collection type gid is not specified,
          # use the default collection type (provides backward compatibility with versions < Hyrax 2.1.0)
          @collection.collection_type_gid = params[:collection_type_gid].presence || default_collection_type.gid
          @collection.attributes = collection_params.except(:members, :parent_id, :collection_type_gid)
          @collection.apply_depositor_metadata(current_user.user_key)
          add_members_to_collection unless batch.empty?
          @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
          if @collection.save
            after_create
          else
            after_create_error
          end
        end

        private

          def authorize_admin
            redirect_to root_path and return unless current_user.admin?
          end

          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Media List")
          end

          def collection_class
            MediaList
          end

          def collection_params
            col_params = params.dig(:collection) || params.dig(:media_list)
            form_class.model_attributes(col_params)
          end

          def member_params
            params.dig(:collection,:members) ||
            params.dig(:media_list,:members)
          end

          def thumbnail_params
            params.dig(:collection,:representative_id) ||
            params.dig(:media_list, :representative_id)
          end

      end
    end
  end
end
