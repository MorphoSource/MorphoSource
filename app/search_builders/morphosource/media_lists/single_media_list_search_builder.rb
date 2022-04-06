# frozen_string_literal: true
module Morphosource
  module MediaLists
    class SingleMediaListSearchBuilder < ::Hyrax::SingleCollectionSearchBuilder

      def models
        [MediaList]
      end

    end
  end
end
