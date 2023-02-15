module Morphosource
  module Collections
    module MediaLists
      class SequentialSectionListsController < Morphosource::Collections::MediaListsController

        self.presenter_class = Morphosource::Collections::MediaLists::SequentialSectionListPresenter

        skip_load_and_authorize_resource only: [:show, :about, :facet], instance_name: :sequential_section_list

        before_action :redirect_to_collection_type, only: []

        private

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.sequential_section_list_media_path(@curation_concern, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          args.merge!(request.params)
          main_app.sequential_section_list_media_facet_path(@collection.id, args)
        end

        def collection_type
          Hyrax::CollectionType.find_by(title: 'Sequential Section List')
        end

      end
    end
  end
end
