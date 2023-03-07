module Morphosource
  module CollectionTypes
    module SequentialSectionLists

      # Settings used by morphosource.rake when creating Sequential Section List collection type
      SETTINGS = {
        title: "Sequential Section List",
        description: "Assortment of media records created from a single object. Multiple users can manage sequential section lists.",
        machine_id: "sequential_section_list",
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