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

        private


          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Media List")
          end

          def collection_class
            MediaList
          end

      end
    end
  end
end
