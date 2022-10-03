module Morphosource
  module Collections
    module MediaLists
      class SequentialSectionListsController < Morphosource::Collections::MediaListsController

        skip_load_and_authorize_resource only: [:show, :about, :facet], instance_name: :sequential_section_list

        before_action :redirect_to_collection_type, only: []

      end
    end
  end
end
