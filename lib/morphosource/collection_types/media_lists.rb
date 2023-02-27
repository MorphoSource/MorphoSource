module Morphosource
  module CollectionTypes
    module MediaLists

      # Settings used by morphosource.rake when creating Media List collection type
      SETTINGS = {
        title: "Media List",
        description: "Assortment of media records. Media records can belong to multiple media lists. Multiple users can manage media lists.",
        machine_id: "media_list",
        nestable: false,
        discoverable: true,
        sharable: true,
        allow_multiple_membership: true,
        require_membership: false,
        assigns_workflow: false,
        assigns_visibility: false,
        share_applies_to_new_works: false,
        brandable: true,
        badge_color: "#"
      }

    end
  end
end