module Morphosource
  module Dashboard
    module Collections
      module MediaLists
        class SequentialSectionListsController < Morphosource::Dashboard::Collections::MediaListsController

          skip_load_and_authorize_resource only: [:edit, :update, :new, :members, :create], instance_name: :sequential_section_list

          before_action :redirect_to_collection_type, only: []

          self.presenter_class = Morphosource::Collections::MediaLists::SequentialSectionListPresenter

          self.form_class = Morphosource::Forms::Collections::MediaLists::SequentialSectionListForm

          private

            def collection_type
              Hyrax::CollectionType.find_by(title: "Sequential Section List")
            end
            alias :default_collection_type :collection_type

            def collection_class
              SequentialSectionList
            end
        end
      end
    end
  end
end
