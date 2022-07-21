module Morphosource
  module Dashboard
    module Collections
      class TeamsController < Morphosource::Dashboard::CollectionsController

        before_action :redirect_to_collection_type, only: []


        def edit
          # byebug
          @subcollections = []
          super
        end
      end
    end
  end
end
