module Morphosource
  module Collections
    module ProjectHelper
      include Morphosource::CollectionHelper

      # def showpage_url(id, tab)
      #   byebug
      #   Rails.application.routes.url_helpers.project_path(id) + "\##{tab}"
      # end

      def media_tab_url
        "/projects/#{@collection.id}" + locale
      end

      def specimens_tab_url
        "/projects/#{@collection.id}/specimens" + locale
      end

      def chos_tab_url
        "/projects/#{@collection.id}/cultural_heritage_objects" + locale
      end

      def about_tab_url
        "/projects/#{@collection.id}/about" + locale
      end

    end
  end
end
