module Morphosource
  module Dashboard
    module Collections
      class MediaListsController < Morphosource::Dashboard::CollectionsController
        skip_load_and_authorize_resource only: [:edit, :update, :new, :members], instance_name: :media_list

        before_action :redirect_to_collection_type, only: []
        before_action :build_breadcrumbs, only: []
        before_action :load_collection

        self.presenter_class = Morphosource::Collections::MediaListPresenter

        private

          def default_collection_type
            Hyrax::CollectionType.find_by(title: "Media List")
          end
      end
    end
  end
end
