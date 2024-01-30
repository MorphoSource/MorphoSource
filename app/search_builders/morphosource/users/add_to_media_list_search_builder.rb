# Retrieves all media a user can edit or has been granted read access to through a role (collection members group)
# + all published media for adding media to a media list
module Morphosource
  module Users
    class AddToMediaListSearchBuilder < MyMediaSearchBuilder

      private

        def read_grants_filters
          filters = []
          filters += read_groups_params
          filters += download_groups_params
          filters += edit_groups_params
          filters += edit_user_params
          filters += read_user_params
          filters += published_params
        end

        def published_params
          ["(visibility_ssi:open)"]
        end

    end
  end
end