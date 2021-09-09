module Morphosource
  module Collections
    class TeamPresenter < Morphosource::CollectionPresenter

      def organization
        @organization ||= @collection.organization
      end
    end
  end
end
