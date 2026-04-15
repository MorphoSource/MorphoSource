module Morphosource
  module Users
    class ManagedOrganizationsSearchBuilder < Morphosource::Users::ManagedCollectionsSearchBuilder
      # returns the organizations managed by @user viewable by @current_user

      def blacklight_config
        OrganizationsCatalogController.blacklight_config
      end

      private

      def models
        [::OrganizationCollection]
      end
    end
  end
end