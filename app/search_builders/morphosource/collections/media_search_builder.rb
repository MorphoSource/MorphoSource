module Morphosource
  module Collections
    class MediaSearchBuilder < Hyrax::CollectionMemberSearchBuilder

      def models
        [Media]
      end

    end
  end
end
