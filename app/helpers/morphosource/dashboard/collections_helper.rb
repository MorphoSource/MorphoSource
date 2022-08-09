module Morphosource
  module Dashboard
    module CollectionsHelper

      def details_tab_url(collection)
        if collection.project?
          project_edit_path(collection)
        elsif collection.team?
          team_edit_path(collection)
        end
      end

      def projects_tab_url(collection)
        team_projects_path(collection)
      end

      def organization_tab_url(collection)
        team_organization_path(collection)
      end

      def members_tab_url(collection)
        if collection.project?
          project_members_path(collection)
        elsif collection.team?
          team_members_path(collection)
        end
      end



    end
  end
end
