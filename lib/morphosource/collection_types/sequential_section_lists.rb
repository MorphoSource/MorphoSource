module Morphosource
  module CollectionTypes
    module SequentialSectionLists

      # Settings used by morphosource.rake when creating Sequential Section List collection type
      SETTINGS = {
        title: "Sequential Section List",
        description: "Assortment of media and physical object records. Media and physical object records can belong to multiple lists. Multiple users or teams can manage lists.",
        machine_id: "sequential_section_list",
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