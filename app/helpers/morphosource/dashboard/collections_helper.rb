module Morphosource
  module Dashboard
    module CollectionsHelper

      def details_tab_url(collection)
        collection_type = collection.collection_type.machine_id
        main_app.send("#{collection_type + '_edit_path'}", collection)
      end

      def members_tab_url(collection)
        collection_type = collection.collection_type.machine_id
        main_app.send("#{collection_type + '_members_path'}", collection)
      end

      def projects_tab_url(collection)
        team_projects_path(collection)
      end

      def organization_tab_url(collection)
        team_organization_path(collection)
      end

      def new_collection_url(collections_type)
        main_app.send("new_#{collections_type.chop}_path")
      end
    end
  end
end
