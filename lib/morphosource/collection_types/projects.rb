module Morphosource
  module CollectionTypes
    module Projects

      # Settings used by morphosource.rake when creating Project collection type
      SETTINGS = {
        title: "Project",
        description: "Assortment of media and physical object records. Media and physical object records can belong to multiple projects. Multiple users or teams can manage projects.",
        machine_id: "project",
        nestable: true,
        discoverable: true,
        sharable: true,
        allow_multiple_membership: true,
        require_membership: false,
        assigns_workflow: false,
        assigns_visibility: true,
        share_applies_to_new_works: true,
        brandable: true,
        badge_color: "#003880"
      }

    end
  end
end
