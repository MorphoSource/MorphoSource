module Morphosource
  module UserWorks
    class MediaSearchBuilder < Morphosource::UserWorksSearchBuilder

      def models
        [Media]
      end

    end
end
