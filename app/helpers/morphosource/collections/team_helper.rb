module Morphosource
  module Collections
    module TeamHelper
      include Morphosource::CollectionHelper

      def showpage_url(id, tab)
        byebug
        Rails.application.routes.url_helpers.project_path(id) + "\##{tab}"
      end

    end
  end
end
