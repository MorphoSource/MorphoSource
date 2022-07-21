module Morphosource
  module Dashboard
    module Collections
      class TeamsController < Morphosource::Dashboard::CollectionsController

        def edit
          # byebug
          @subcollections = []
          super
        end
      end
    end
  end
end
