# frozen_string_literal: true

module Morphosource
  module Dashboard
    # Overrides the set_default_permissions method from Hyrax::Dashboard::CollectionsController
    # If collection being created is a team or project, create collection groups and appropriate access grants.
    module CollectionsControllerBehavior

      def set_default_permissions
        if @collection.type_assigns_groups?
          set_morphosource_permissions
        else
          additional_grants = @participants # Grants converted from older versions (< Hyrax 2.1.0) where share was edit or read access instead of managers, depositors, and viewers
          Hyrax::Collections::PermissionsCreateService.create_default(collection: @collection, creating_user: current_user, grants: additional_grants)
        end
      end

      def set_morphosource_permissions
        @collection.create_collection_groups
        @collection.copy_parent_membership(params[:parent_id]) unless params[:parent_id].nil?
        Morphosource::Collections::PermissionsCreateService.create_default(collection: @collection)
      end
    end
  end
end
