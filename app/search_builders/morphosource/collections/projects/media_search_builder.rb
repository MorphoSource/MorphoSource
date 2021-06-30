module Morphosource
  module Collections
    module Projects
      class MediaSearchBuilder < Hyrax::CollectionMemberSearchBuilder

        def models
          [Media]
        end

      end
    end
  end
end
