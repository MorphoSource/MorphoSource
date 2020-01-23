module Morphosource
  module CollectionTypes
    module Teams

      # Settings used by morphosource.rake when creating Team collection type
      SETTINGS = {
        title: "Team",
        description: "Group of users belonging to the same institution, organization, department, collection, or lab. Teams can manage projects collectively.",
        machine_id: "team",
        nestable: true,
        discoverable: true,
        sharable: true,
        allow_multiple_membership: true,
        require_membership: false,
        assigns_workflow: false,
        assigns_visibility: true,
        share_applies_to_new_works: true,
        brandable: true,
        badge_color: "#FF861F"
      }

    end
  end
end
