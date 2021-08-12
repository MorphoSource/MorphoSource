module Morphosource
  module Collections
    module ProjectHelper
      include Morphosource::CollectionHelper

      def media_tab_url(type)
        "/#{type}/#{@collection.id}" + locale
      end

      def specimens_tab_url(type)
        "/#{type}/#{@collection.id}/specimens" + locale
      end

      def chos_tab_url(type)
        "/#{type}/#{@collection.id}/cultural_heritage_objects" + locale
      end

      def about_tab_url(type)
        "/#{type}/#{@collection.id}/about" + locale
      end

    end
  end
end
