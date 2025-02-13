module Morphosource
  module Breadcrumbs
    module Works
      extend ActiveSupport::Concern
      include Morphosource::Breadcrumbs

      private

      # Home / Dashboard / Media and Objects /
      def add_dashboard_path
        super
        add_breadcrumb t(:'morphosource.dashboard.sidebar.my_media.media_and_objects'), main_app.my_media_index_path
      end
    end
  end
end