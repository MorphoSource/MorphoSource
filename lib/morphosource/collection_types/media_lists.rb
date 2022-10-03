module Morphosource
  module CollectionTypes
    module MediaLists

      # Settings used by morphosource.rake when creating Media List collection type
      SETTINGS = {
        title: "Media List",
        description: "Assortment of media and physical object records. Media and physical object records can belong to multiple projects. Multiple users or teams can manage projects.",
        machine_id: "media_list",
        nestable: false,
        discoverable: true,
        sharable: true,
        allow_multiple_membership: true,
        require_membership: false,
        assigns_workflow: false,
        assigns_visibility: true,
        share_applies_to_new_works: false,
        brandable: true,
        badge_color: "#"
      }

    end
  end
end