module Morphosource
  module Dashboard
    module Collections
      class MediaListsController < Morphosource::Dashboard::CollectionsController
        skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create], instance_name: :media_list

        before_action :redirect_to_collection_type, only: []
        skip_before_action :authorize_contributor

        self.presenter_class = Morphosource::Collections::MediaListPresenter

        self.form_class = Morphosource::Forms::Collections::MediaListForm

        private


          def collection_type
            Hyrax::CollectionType.find_by(title: "Media List")
          end
          alias :default_collection_type :collection_type

          def collection_class
            MediaList
          end

      end
    end
  end
end
